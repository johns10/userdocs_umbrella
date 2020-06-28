defmodule UserDocsWeb.PageLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation
  alias UserDocs.Web

  alias UserDocsWeb.ProcessLive
  alias UserDocsWeb.ElementLive
  alias UserDocsWeb.AnnotationLive
  alias UserDocsWeb.Layout

  @impl true
  def render(assigns) do
    ~L"""
    <%= live_group(@socket,
      ProcessLive.ShowComponent,
      ProcessLive.FormComponent,
      [
        title: "Processes",
        type: :process,
        parent_type: :page,
        struct: %Automation.Process{},
        objects: @object.processes,
        return_to: Routes.process_index_path(@socket, :index),
        id: "page-"
          <> Integer.to_string(@object.id)
          <> "-processes",
        parent: @object
      ]
    ) %>
    <%= live_group(@socket,
      ElementLive.ShowComponent,
      ElementLive.FormComponent,
      [
        title: "Elements",
        type: :element,
        parent_type: :page,
        struct: %Web.Element{},
        objects: @object.elements,
        return_to: Routes.element_index_path(@socket, :index),
        id: "page-"
          <> Integer.to_string(@object.id)
          <> "-elements",
        parent: @object
      ]
    ) %>
    <%= live_group(@socket,
      AnnotationLive.ShowComponent,
      AnnotationLive.FormComponent,
      [
        title: "Annotations",
        type: :annotation,
        parent_type: :page,
        struct: %Web.Annotation{},
        objects: @object.annotations,
        return_to: Routes.annotation_index_path(@socket, :index),
        id: "page-"
          <> Integer.to_string(@object.id)
          <> "-annotation",
        parent: @object
      ]
    ) %>
    """
  end

  @impl true
  def handle_event("expand", _, socket) do
    socket = assign(socket, :expanded, not socket.assigns.expanded)
    {:noreply, socket}
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
