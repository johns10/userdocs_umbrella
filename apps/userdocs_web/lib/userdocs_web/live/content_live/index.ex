defmodule UserDocsWeb.ContentLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Users
  alias UserDocs.Documents
  alias UserDocs.Projects
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.ContentVersion
  alias UserDocs.Helpers

  alias UserDocsWeb.ComposableBreadCrumb
  alias UserDocsWeb.Root
  alias UserDocsWeb.Defaults
  alias UserDocsWeb.Loaders

  @types [
    UserDocs.Users.Team,
    UserDocs.Projects.Version,
    UserDocs.Documents.Content,
    UserDocs.Documents.ContentVersion,
    UserDocs.Documents.LanguageCode
  ]

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, @types)
      |> initialize()
    }
  end

  def initialize(%{ assigns: %{ auth_state: :logged_in }} = socket) do
    opts = Defaults.opts(socket, @types)
    socket
    |> load_language_codes(opts)
    |> load_content(opts)
    |> load_content_versions(opts)
    |> load_teams(opts)
    |> load_versions(opts)
  end
  def initialize(socket), do: socket

  @impl true
  def handle_params(%{ "team_id" => team_id } = params, url, socket) do
    team = Users.get_team!(team_id, %{ preloads: %{ job: %{ step_instances: true, process_instances: true }}})
    socket = assign(socket, :current_team, team)
    do_handle_params(params, url, socket)
  end
  def handle_params(%{} = params, url, socket) do
    do_handle_params(params, url, socket)
  end

  def do_handle_params(params, _url, socket) do
    {
      :noreply,
      socket
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, [ :content_versions, [ content_versions: :version ] ])
    content = Documents.get_content!(String.to_integer(id), socket, opts)
    socket
    |> assign(:page_title, "Edit Content")
    |> assign(:content, content)
    |> assign(:select_lists, select_lists(socket))
    |> prepare_content()
  end
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Content")
    |> assign(:select_lists, select_lists(socket))
    |> assign(:content, %Content{})
    |> prepare_content()
  end
  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Content")
    |> assign(:content, nil)
    |> prepare_content()
  end
  defp apply_action(socket, _, _), do: socket

  defp select_lists(socket) do
    opts = socket.assigns.state_opts
    %{
      teams:
        Users.list_teams(socket, opts)
        |> Helpers.select_list(:name, false),
      versions:
        Projects.list_versions(socket, opts)
        |> Helpers.select_list(:name, false),
      language_codes:
        Documents.list_language_codes(socket, opts)
        |> Helpers.select_list(:name, false),
      content:
        Documents.list_content(socket, opts)
        |> Helpers.select_list(:name, false)
    }
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    content = Documents.get_content!(id)
    {:ok, deleted_content} = Documents.delete_content(content)
    send(self(), { :broadcast, "delete", deleted_content })
    {:noreply, socket}
  end
  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  def handle_info(%{topic: _, event: _, payload: %{ objects: [ %ContentVersion{} | _ ]}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_content(socket) }
  end
  def handle_info(%{topic: _, event: _, payload: %Content{}} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    { :noreply, prepare_content(socket) }
  end
  @impl true
  def handle_info(%{topic: _, event: _, payload: %UserDocs.Users.User{} = user} = sub_data, socket) do
    { :noreply, socket } = Root.handle_info(sub_data, socket)
    {
      :noreply,
      socket
      |> prepare_content()
      |> push_patch(to: Routes.content_index_path(socket, :index))
    }
  end
  def handle_info(n, s), do: Root.handle_info(n, s)

  defp prepare_content(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:filter, { :team_id, socket.assigns.current_team.id })
      |> Keyword.put(:preloads, [ :content_versions, [ content_versions: :version ] ])
      |> Keyword.put(:order, [ %{ field: :id, order: :asc } ])

    socket
    |> assign(:contents, Documents.list_content(socket, opts))
  end

  defp load_content(socket, opts), do: Loaders.load_content(socket, opts)
  def load_content_versions(socket, opts), do: Loaders.load_content_versions(socket, opts)
  def load_language_codes(socket, opts), do: Documents.load_language_codes(socket, opts)
  def load_teams(socket, opts) do
    opts = Keyword.put(opts, :filters, %{ user_id: socket.assigns.current_user.id })
    Users.load_teams(socket, opts)
  end
  def load_versions(socket, opts) do
    opts = Keyword.put(opts, :filters, %{ user_id: socket.assigns.current_user.id })
    Projects.load_versions(socket, opts)
  end
end
