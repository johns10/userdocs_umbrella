defmodule UserDocsWeb.ProcessAdministratorLive.Index do
  use UserDocsWeb, :live_view

  require Logger

  use UserdocsWeb.LiveViewPowHelper

  alias UserDocsWeb.ID
  alias UserDocsWeb.ProcessLive
  alias UserDocsWeb.StepLive
  alias UserDocsWeb.ProcessAdministratorLive.Loaders

  alias UserDocsWeb.ModalMenus, as: ModalMenus

  alias UserDocs.Automation.Step
  alias UserDocs.Users
  alias UserDocs.Web
  alias UserDocs.Web.Strategy
  alias UserDocs.Automation
  alias UserDocs.Projects
  alias UserDocs.Documents
  alias UserDocs.Documents.Content

  alias UserDocsWeb.CollapsableFormComponent
  alias UserDocsWeb.GroupComponent
  alias UserDocsWeb.Root

  @subscribed_types [
    UserDocs.Automation.Process,
    UserDocs.Automation.Step,
    UserDocs.Web.Annotation,
    UserDocs.Web.Element,
    UserDocs.Web.Page
  ]

  @types [
    UserDocs.Web.AnnotationType,
    UserDocs.Web.Strategy,
    UserDocs.Documents.LanguageCode,
    UserDocs.Automation.StepType,
    UserDocs.Documents.Content,
    UserDocs.Documents.ContentVersion,
    UserDocs.Automation.Process,
    UserDocs.Automation.Step,
    UserDocs.Web.Annotation,
    UserDocs.Web.Element,
    UserDocs.Web.Page
  ]

  defp base_opts() do
    UserDocsWeb.Defaults.state_opts()
    |> Keyword.put(:location, :data)
    |> Keyword.put(:types, @types)
  end

  defp state_opts(socket) do
    base_opts()
    |> Keyword.put(:broadcast, true)
    |> Keyword.put(:channel, UserDocsWeb.Defaults.channel(socket))
    |> Keyword.put(:broadcast_function, &UserDocsWeb.Endpoint.broadcast/3)
  end

  @impl true
  def mount(_params, session, socket) do
    # Get Data from the Database
    Logger.debug("DB operations")
    opts = base_opts()

    socket =
      socket
      |> Root.authorize(session)
      |> Root.initialize(opts)
      |> initialize()
      |> assign(:form_data, %{ action: :show })

    {:ok, socket}
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = state_opts(socket)

    socket
    |> assign(:modal_action, :show)
    |> assign(:transferred_strategy, %Strategy{})
    |> assign(:transferred_selector, "")
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Documents.load_language_codes(opts)
    |> Automation.load_step_types(opts)
    |> Loaders.content(opts)
    |> Loaders.content_versions(opts)
    |> Select.assign_default_strategy_id(&assign/3, opts)
    |> send_default_strategy()
    |> Loaders.processes(opts)
    |> Loaders.steps(opts)
    |> Loaders.annotations(opts)
    |> Loaders.elements(opts)
    |> Loaders.pages(opts)
    |> prepare_version()
    |> assign(:process_menu, [])
    |> assign(:state_opts, opts)
  end
  def initialize(socket), do: socket
  @impl true
  def handle_info(%{topic: _, event: _, payload: %Content{}} = sub_data, socket) do
    opts = state_opts(socket)

    { :noreply, socket } =
      Root.handle_info(sub_data, socket)

    {
      :noreply,
      socket
      |> Loaders.content(opts)
      |> Loaders.content_versions(opts)
    }
  end
  def handle_info(%{topic: _, event: _, payload: payload} = sub_data, socket) do
    case is_in_list(payload, @subscribed_types) do
      true ->
        { :noreply, socket } = Root.handle_info(sub_data, socket)
        { :noreply, prepare_version(socket) }
      false ->
        { :noreply, socket }

    end
  end
  def handle_info({ :transfer_selector, %{ "selector" => selector, "strategy" => strategy } }, socket) do
    strategy =
      Web.list_strategies
      |> Enum.filter(fn(s) -> s.name == strategy end)
      |> Enum.at(0)

    {
      :noreply,
      socket
      |> assign(:transferred_strategy, strategy)
      |> assign(:transferred_selector, selector)
    }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  def is_in_list(item, list) do
    Enum.reduce(list, false,
      fn(type, acc) ->
        case is_struct(item, type) do
          true -> true
          false -> acc
        end
      end
    )
  end


  def filter(socket, data_key, { filter_key, value }) do
    socket.assigns
    |> Map.get(data_key)
    |> Enum.filter(fn(o) -> Map.get(o, filter_key) == value end)
  end
  def filter(socket, data_key, {}) do
    socket.assigns
    |> Map.get(data_key)
  end

  def content_class([]), do: "content is-hidden"
  def content_class(_), do: "content"

  @impl true
  def handle_event("update_current_strategy", %{"current_strategy" => %{ "strategy_id" => id }}, socket) do
    strategy =
      socket.assigns.data.strategies
      |> Enum.filter(fn(s) -> s.id == String.to_integer(id) end)
      |> Enum.at(0)

    message = %{
      type: "configuration",
      payload: %{
        strategy: Strategy.safe(strategy)
      }
    }

    {
      :noreply,
      socket
      |> push_event("configure", message)
      |> assign(:current_strategy, strategy)
    }
  end
  def handle_event("new-step" = name, %{ "process-id" => process_id }, socket) do
    process_id = String.to_integer(process_id)
    opts = Keyword.put(socket.assigns.state_opts, :preloads, [ :steps ])
    params =
      %{}
      |> Map.put(:process_id, process_id)
      |> Map.put(:process, Automation.get_process!(process_id, socket, opts))
      |> Map.put(:processes, Automation.list_processes(socket, socket.assigns.state_opts))
      |> Map.put(:step_types, Automation.list_step_types(socket, socket.assigns.state_opts))
      |> Map.put(:annotation_types, Web.list_annotation_types(socket, socket.assigns.state_opts))
      |> Map.put(:state_opts, socket.assigns.state_opts)

    Root.handle_event(name, params, socket)
  end
  def handle_event("new-process" = name, %{ "current-project-id" => project_id, "current-version-id" => version_id }, socket) do
    params =
      %{}
      |> Map.put(:project_id, String.to_integer(project_id))
      |> Map.put(:version_id, String.to_integer(version_id))
      |> Map.put(:versions, Projects.list_versions(socket, socket.assigns.state_opts))

    Root.handle_event(name, params, socket)
  end
  def handle_event("new-content" = n, _params, socket) do
    team = Users.get_team!(socket.assigns.current_team_id, socket, state_opts(socket))
    params =
      %{}
      |> Map.put(:version_id, socket.assigns.current_version_id)
      |> Map.put(:teams, socket.assigns.data.teams)
      |> Map.put(:language_codes, Documents.list_language_codes(socket, state_opts(socket)))
      |> Map.put(:team, team)
      |> Map.put(:versions, socket.assigns.data.versions)
      |> Map.put(:content, socket.assigns.data.content)
      |> Map.put(:channel, UserDocsWeb.Defaults.channel(socket))
      |> Map.put(:state_opts, state_opts(socket))

    Root.handle_event(n, params, socket)
  end

  def send_default_strategy(%{ assigns: %{ current_strategy_id: id }} = socket) do
    #TODO: Use state
    strategy =
      Web.list_strategies()
      |> Enum.filter(fn(s) -> s.id == id end)
      |> Enum.at(0)

    message = %{
      type: "configuration",
      payload: %{
        strategy: Strategy.safe(strategy)
      }
    }

    socket
    |> push_event("configure", message)
    |> assign(:current_strategy, strategy)
  end

  def prepare_version(socket) do
    IO.puts("Preparing Version")
    preloads =
      [
        :processes,
        [ processes: :steps ],
        [ processes: [ steps: :step_type ] ],
        [ processes: [ steps: :page ] ],
        [ processes: [ steps: :annotation ] ],
        [ processes: [ steps: [ annotation: :annotation_type ] ] ],
        [ processes: [ steps: :element ] ],
        [ processes: [ steps: [ element: :strategy ] ] ],
      ]

    order =
      [
        processes: %{ field: :name, order: :asc },
        processes: [ steps: %{ field: :order, order: :asc } ]
      ]

    opts =
      state_opts(socket)
      |> Keyword.put(:preloads, preloads)
      |> Keyword.put(:order, order)

    assign(socket, :current_version, Projects.get_version!(socket.assigns.current_version_id, socket, opts))
  end

  def recent_page_id(process, step, pages) do
    case maybe_step_page_id(step) |> maybe_recent_page_id(process, step, pages) do
      { :ok, result } -> result
      { :nok, _ } -> nil
    end
  end

  def maybe_step_page_id(%Step{ page_id: nil } = step) do
    #IO.puts("page id nul")
    { :nok, step }
  end
  def maybe_step_page_id(%Step{ page_id: page_id }) do
    #IO.puts("page id")
    { :ok, page_id }
  end

  def maybe_recent_page_id({ :ok, result }, _, _, _) do
    #IO.puts("maybe_recent_page_id ok")
    { :ok, result }
  end
  def maybe_recent_page_id({ :nok, result }, process, step, pages) do
    case UserDocs.Automation.Process.RecentPage.get(process, step, pages) do
      nil ->
        #IO.puts("Nil recent page id")
        { :nok, result }
      page ->
        #IO.puts("Got recent page id")
        { :ok, Map.get(page, :id) }
    end
  end
end
