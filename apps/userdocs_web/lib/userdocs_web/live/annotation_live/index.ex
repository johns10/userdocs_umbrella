defmodule UserDocsWeb.AnnotationLive.Index do
  use UserDocsWeb, :live_view
  use UserdocsWeb.LiveViewPowHelper

  alias UserDocs.Annotations
  alias UserDocs.Annotations.Annotation
  alias UserDocs.Annotations.AnnotationType
  alias UserDocs.Helpers
  alias UserDocs.Web
  alias UserDocsWeb.Root
  alias UserDocsWeb.ProcessLive.Loaders

  def data_types do
    [
      UserDocs.Annotations.AnnotationType,
      UserDocs.Annotations.Annotation,
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
    |> Annotations.load_annotation_types(opts)
    |> Loaders.pages(opts)
    |> Loaders.elements(opts)
    |> Loaders.annotations(opts)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id, "page_id" => page_id}) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:page_title, "Edit Annotation")
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, opts))
    |> assign(:annotation, Annotations.get_annotation!(id))
    |> prepare_annotations(String.to_integer(page_id))
    |> assign_select_lists
  end

  defp apply_action(socket, :new, %{"page_id" => page_id}) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:page_title, "New Annotation")
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, opts))
    |> assign(:annotation, %Annotation{})
    |> assign_select_lists
  end

  defp apply_action(socket, :index, %{"page_id" => page_id}) do
    opts = socket.assigns.state_opts
    socket
    |> assign(:page_title, "Listing Annotation")
    |> assign(:page, Web.get_page!(String.to_integer(page_id), socket, opts))
    |> assign(:annotation, nil)
    |> prepare_annotations(String.to_integer(page_id))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    annotation = Annotations.get_annotation!(id)
    {:ok, _} = Annotations.delete_annotation(annotation)

    {:noreply, socket}
  end

  @preloads [:annotation_type]
  @order [%{field: :name, order: :asc}]
  defp prepare_annotations(socket, page_id) do
     opts =
       socket.assigns.state_opts
       |> Keyword.put(:preloads, @preloads)
       |> Keyword.put(:order, @order)
       |> Keyword.put(:filter, {:page_id, page_id})

    assign(socket, :annotations, Annotations.list_annotations(socket, opts))
  end

  def assign_select_lists(socket) do
    assign(socket, :select_lists, %{
      pages: pages_select(socket),
      annotation_types: annotation_types_select(socket)
    })
  end

  def pages_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Web.list_pages(socket, state_opts)
    |> Helpers.select_list(:name, :true)
  end

  def annotation_types_select(%{assigns: %{state_opts: state_opts}} = socket) do
    Annotations.list_annotation_types(socket, state_opts)
    |> Helpers.select_list(:name, :false)
  end
end
