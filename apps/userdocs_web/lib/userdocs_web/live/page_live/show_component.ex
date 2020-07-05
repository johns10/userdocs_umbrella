defmodule UserDocsWeb.PageLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation
  alias UserDocs.Web

  alias UserDocsWeb.ProcessLive
  alias UserDocsWeb.ElementLive
  alias UserDocsWeb.AnnotationLive

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <%= live_group(@socket,
        ProcessLive.ShowComponent,
        ProcessLive.FormComponent,
        [
          title: "Processes",
          type: :process,
          parent_type: :page,
          struct: %Automation.Process{},
          objects: @page.processes,
          return_to: Routes.process_index_path(@socket, :index),
          id: "page-"
            <> Integer.to_string(@page.id)
            <> "-processes",
          parent: @page,
          select_lists: @select_lists
          |> Map.put(:available_elements, @page.elements)
          |> Map.put(:available_annotations, @page.annotations)
          |> Map.put(:available_processes, @page.processes)
        ]
      ) %>
      <hr>
      <%= live_group(@socket,
        ElementLive.ShowComponent,
        ElementLive.FormComponent,
        [
          title: "Elements",
          type: :element,
          parent_type: :page,
          struct: %Web.Element{},
          objects: @page.elements,
          return_to: Routes.element_index_path(@socket, :index),
          id: "page-"
            <> Integer.to_string(@page.id)
            <> "-elements",
          parent: @page,
          select_lists: @select_lists
        ]
      ) %>
      <hr>
      <%= live_group(@socket,
        AnnotationLive.ShowComponent,
        AnnotationLive.FormComponent,
        [
          title: "Annotations",
          type: :annotation,
          parent_type: :page,
          struct: %Web.Annotation{},
          objects: @page.annotations,
          return_to: Routes.annotation_index_path(@socket, :index),
          id: "page-"
            <> Integer.to_string(@page.id)
            <> "-annotation",
          parent: @page,
          select_lists: @select_lists
          |> Map.put(:available_elements, @page.elements)
        ]
      ) %>
    </div>
    """
  end

  @impl true
  def handle_event("expand", _, socket) do
    {:noreply, assign(socket, :expanded, not socket.assigns.expanded)}
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, false)
      |> assign(:action, :show)

      {:ok, socket}
  end
end
