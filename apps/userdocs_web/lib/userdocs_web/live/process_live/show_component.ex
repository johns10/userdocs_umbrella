defmodule UserDocsWeb.ProcessLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation

  alias UserDocsWeb.StepLive.ShowComponent
  alias UserDocsWeb.StepLive.FormComponent

  @impl true
  def render(assigns) do
    ~L"""
    <%= live_group(@socket, ShowComponent, FormComponent,
      [
        title: "Steps",
        type: :step,
        parent_type: :process,
        struct: %Automation.Step{},
        objects: @process.steps,
        return_to: Routes.step_index_path(@socket, :index),
        id: "process-"
          <> Integer.to_string(@process.id)
          <> "-steps",
        parent: @process,
        select_lists: @select_lists
      ]
    ) %>
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
