defmodule UserDocsWeb.ElementLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Elements
  alias UserDocs.Elements.Element
  alias UserDocs.Helpers
  alias UserDocs.Pages
  alias UserDocs.Web
  alias UserDocsWeb.Root
  alias UserDocsWeb.ProcessLive.Loaders

  def data_types do
    [
      UserDocs.Web.Strategy,
      UserDocs.Elements.Element,
      UserDocs.Pages.Page
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
    |> Web.load_strategies(opts)
    |> Loaders.pages(opts)
    |> Loaders.elements(opts)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"page_id" => page_id, "element_id" => element_id}) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:page_title, "Edit Element")
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, opts))
    |> assign(:element, Elements.get_element!(String.to_integer(element_id), socket, opts))
    |> prepare_elements(String.to_integer(page_id))
    |> assign_select_lists
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Element")
    |> assign(:page, Web.get_page!(String.to_integer(id), socket, socket.assigns.state_opts))
    |> assign(:element, Elements.get_element!(id))
    |> prepare_elements()
  end

  defp apply_action(socket, :new, %{"page_id" => page_id}) do
    socket
    |> assign(:page_title, "New Element")
    |> prepare_elements(String.to_integer(page_id))
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, socket.assigns.state_opts))
    |> assign(:element, %Element{})
    |> assign_select_lists
  end

  defp apply_action(socket, :index, %{"page_id" => page_id}) do
    socket
    |> assign(:page_title, "Listing Elements")
    |> assign(:element, nil)
    |> prepare_elements(String.to_integer(page_id))
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, socket.assigns.state_opts))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Elements")
    |> assign(:element, nil)
    |> assign(:page, nil)
  end

  @impl true
  def handle_event("apply_highlights", %{"element" => %{"id" => id, "highlight" => highlight}} = params, socket) do
    IO.puts("Applying highlight")
    user_id = "user:" <> to_string(socket.assigns.current_user.id)
    opts = socket.assigns.state_opts |> Keyword.put(:preloads, [:strategy])
    element = Elements.get_element!(String.to_integer(id), socket, opts)
    case highlight do
      "true" ->
        UserDocsWeb.Endpoint.broadcast(user_id, "command:highlight_element", element)
      "false" ->
        UserDocsWeb.Endpoint.broadcast(user_id, "command:unhighlight_element", element)
    end
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id, "page-id" => page_id}, socket) do
    element = Elements.get_element!(id)
    {:ok, deleted_element} = Elements.delete_element(element)
    send(self(), {:broadcast, "delete", deleted_element})
    elements = Enum.filter(socket.assigns.elements, fn(e) -> e.id != deleted_element.id end)
    {:noreply, socket |> assign(:elements, elements)}
  end

  @impl true
  def handle_info(n, s), do: Root.handle_info(n, s)

  @preloads [:strategy]
  @order [%{field: :name, order: :asc}]
  defp prepare_elements(socket, page_id) do
     opts =
       socket.assigns.state_opts
       |> Keyword.put(:preloads, @preloads)
       |> Keyword.put(:order, @order)
       |> Keyword.put(:filter, {:page_id, page_id})

    assign(socket, :elements, Elements.list_elements(socket, opts))
  end

  defp prepare_elements(socket) do
    opts =
      socket.assigns.state_opts
      |> Keyword.put(:preloads, @preloads)
      |> Keyword.put(:order, @order)

   assign(socket, :elements, Elements.list_elements(socket, opts))
  end

  def assign_select_lists(socket) do
    assign(socket, :select_lists, %{
      pages_select: pages_select(socket),
      strategies: strategies_select(socket)
    })
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
