defmodule UserDocsWeb.PageLive.Show do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Helpers
  alias UserDocs.Projects
  alias UserDocs.Web
  alias UserDocs.Web.Element
  alias UserDocsWeb.Root
  alias UserDocsWeb.ProcessLive.Loaders

  def data_types do
    [
      UserDocs.Annotations.AnnotationType,
      UserDocs.Web.Strategy,
      UserDocs.Annotations.Annotation,
      UserDocs.Web.Element,
      UserDocs.Web.Page,
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
    |> Web.load_annotation_types(opts)
    |> Web.load_strategies(opts)
    |> Loaders.pages(opts)
    |> Loaders.annotations(opts)
    |> Loaders.elements(opts)
    |> Loaders.projects(opts)
  end


  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:page, Web.get_page!(String.to_integer(id), socket, socket.assigns.state_opts))
    |> prepare_elements(String.to_integer(id))
    |> assign_select_lists
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:page, Web.get_page!(String.to_integer(id), socket, socket.assigns.state_opts))
    |> prepare_elements(String.to_integer(id))
    |> assign_select_lists
  end

  defp apply_action(socket, :edit_element, %{"page_id" => page_id, "element_id" => element_id}) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, opts))
    |> assign(:element, Web.get_element!(String.to_integer(element_id), socket, opts))
    |> prepare_elements(String.to_integer(page_id))
    |> assign_select_lists
  end

  defp apply_action(socket, :new_element, %{"page_id" => page_id}) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, opts))
    |> assign(:element, %Element{})
    |> prepare_elements(String.to_integer(page_id))
    |> assign_select_lists

  end

  defp prepare_elements(socket, page_id) do
    preloads =
      [
        :strategy,
        :annotations,
        [annotation: :annotation_type]
     ]

     opts =
       socket.assigns.state_opts
       |> Keyword.put(:preloads, preloads)
       |> Keyword.put(:order, [%{field: :name, order: :asc}])
       |> Keyword.put(:filter, {:page_id, page_id})

    IO.inspect(Web.list_elements(socket, opts))

    assign(socket, :elements, Web.list_elements(socket, opts))
  end

  defp page_title(:show), do: "Show Page"
  defp page_title(:edit), do: "Edit Page"
  defp page_title(:edit_element), do: "Edit Element"
  defp page_title(:new_element), do: "New Element"

  def parse_element_live_action(:new_element), do: :new
  def parse_element_live_action(:edit_element), do: :edit

  def assign_select_lists(socket) do
    assign(socket, :select_lists, %{
      projects: projects_select(socket),
      pages_select: pages_select(socket),
      strategies: strategies_select(socket)
    })
  end

  def projects_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Projects.list_projects(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end

  def pages_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Web.list_pages(socket, state_opts)
    |> Helpers.select_list(:name, :true)
  end

  def strategies_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Web.list_strategies(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
end
