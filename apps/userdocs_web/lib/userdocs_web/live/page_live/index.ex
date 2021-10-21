defmodule UserDocsWeb.PageLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Helpers
  alias UserDocs.Projects
  alias UserDocs.Web
  alias UserDocs.Web
  alias UserDocs.Pages.Page
  alias UserDocsWeb.Root
  alias UserDocsWeb.ProcessLive.Loaders

  def data_types do
    [
      UserDocs.Pages.Page,
      UserDocs.Projects.Project
   ]
  end

  @impl true
  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> Root.apply(session, data_types())
      |> initialize()
   }
  end

  def initialize(%{assigns: %{auth_state: :not_logged_in}} = socket), do: socket
  def initialize(socket) do
    opts = socket.assigns.state_opts
    socket
    |> Loaders.pages(opts)
    |> Loaders.projects(opts)
  end

  @impl true
  def handle_params(params, url, socket) do
    {
      :noreply,
      socket
      |> assign(url: URI.parse(url))
      |> apply_action(socket.assigns.live_action, params)

    }
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, Web.get_page!(id))
    |> prepare_pages(socket.assigns.current_project.id)
    |> assign_select_lists()
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, %Page{})
    |> prepare_pages(socket.assigns.current_project.id)
    |> assign_select_lists()
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pages")
    |> assign(:page, nil)
    |> prepare_pages(socket.assigns.current_project.id)
    |> assign_select_lists()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Web.get_page!(id)
    {:ok, _} = Web.delete_page(page)

    {:noreply, prepare_pages(socket, socket.assigns.current_project_id)}
  end

  def handle_event("navigate", %{"id" => id}, %{assigns: %{state_opts: opts, current_project: project, current_user: user}} = socket) do
    page = Web.get_page!(String.to_integer(id), socket, opts)
    url = Web.effective_url(page, project, user)
    IO.puts("Sending a navigate command to the extension to #{url}")
    UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "command:navigate", %{url: url})
    {:noreply, socket}
  end

  def handle_event(n, p, s), do: Root.handle_event(n, p, s)

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)

  defp prepare_pages(socket, project_id) do
     opts =
       socket.assigns.state_opts
       |> Keyword.put(:order, [%{field: :name, order: :asc}])
       |> Keyword.put(:filter, {:project_id, project_id})

    assign(socket, :pages, Web.list_pages(socket, opts))
  end

  def assign_select_lists(socket) do
    assign(socket, :select_lists, %{
      projects: projects_select(socket)
    })
  end

  def projects_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Projects.list_projects(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
end
