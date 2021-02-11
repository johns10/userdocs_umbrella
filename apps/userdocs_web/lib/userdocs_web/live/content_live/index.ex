defmodule UserDocsWeb.ContentLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users
  alias UserDocs.Documents
  alias UserDocs.Projects
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion
  alias UserDocs.Documents.LanguageCode

  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Loaders
  alias UserDocsWeb.ModalMenus

  @types [ Content, ContentVersion, LanguageCode ]

  defp base_opts() do
    Defaults.state_opts
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
    opts =
      base_opts()

    {:ok,
      socket
      |> Root.authorize(session)
      |> Root.initialize()
      |> StateHandlers.initialize(opts)
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = state_opts(socket)
    socket
    |> load_language_codes(opts)
    |> load_content(opts)
    |> load_content_versions(opts)
    |> current_selections()
    |> prepare_content()
    |> assign(:state_opts, opts)
    |> StateHandlers.inspect(opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(%{ assigns: %{ auth_state: :logged_in }} = socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Content")
    |> initialize()
    |> ModalMenus.edit_content(edit_params(socket, id, state_opts(socket)))
  end
  defp apply_action(%{ assigns: %{ auth_state: :logged_in }} = socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content")
    |> initialize()
    |> ModalMenus.new_content(params(socket, state_opts(socket)))
  end
  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Content")
    |> initialize()
  end
  defp apply_action(%{ assigns: %{ auth_state: :not_logged_in }} = socket, _, _), do: socket

  defp edit_params(socket, id, opts) do
    params(socket, opts)
    |> Map.put(:content_id, String.to_integer(id))
  end

  defp params(socket, opts) do
    %{}
    |> Map.put(:team, UserDocs.Users.get_team!(socket.assigns.current_team_id, socket, opts))
    |> Map.put(:teams, Users.list_teams(socket, opts))
    |> Map.put(:language_codes, Documents.list_language_codes(socket, opts))
    |> Map.put(:channel, Defaults.channel(socket))
    |> Map.put(:version_id, socket.assigns.current_version_id)
    |> Map.put(:versions, Projects.list_versions(socket, opts))
    |> Map.put(:content, Documents.list_content(socket, opts))
    |> Map.put(:state_opts, opts)
  end

  @impl true
  def handle_event("edit-content" = n, %{ "id" => id }, socket) do
    Root.handle_event(n, edit_params(socket, id, state_opts(socket)), socket)
  end
  def handle_event("new-content" = n, _params, socket) do
    Root.handle_event(n, params(socket, state_opts(socket)), socket)
  end
  def handle_event("delete", %{"id" => id}, socket) do
    content = Documents.get_content!(id)
    {:ok, deleted_content} = Documents.delete_content(content)
    send(self(), { :broadcast, "delete", deleted_content })
    send(self(), :close_modal)
    {:noreply, socket}
  end
  def handle_event("select-version" = n, p, s) do
    { :noreply, socket } = Root.handle_event(n, p, s)
    { :noreply, prepare_content(socket) }
  end

  def handle_info(%{topic: _, event: _, payload: %{ objects: [ %ContentVersion{} | _ ]}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_content(socket) }
  end
  def handle_info(%{topic: _, event: _, payload: %Content{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_content(socket) }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  defp prepare_content(socket) do
    opts =
      state_opts(socket)
      |> Keyword.put(:filter, { :team_id, socket.assigns.current_team_id })
      |> Keyword.put(:preloads, [ :content_versions, [ content_versions: :version ] ])
      |> Keyword.put(:order, [ %{ field: :id, order: :asc } ])

    socket
    |> assign(:content, Documents.list_content(socket, opts))
  end

  defp current_selections(socket) do
    language_code_id =
      socket.assigns.current_team_id
      |> Users.get_team!(socket, state_opts(socket))
      |> Map.get(:default_language_code_id)

    socket
    |> assign(:current_language_code_id, language_code_id)
  end

  defp load_content(socket, opts), do: Loaders.load_content(socket, opts)
  def load_content_versions(socket, opts), do: Loaders.load_content_versions(socket, opts)
  def load_language_codes(socket, opts), do: Documents.load_language_codes(socket, opts)
end
