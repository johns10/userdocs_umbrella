defmodule UserDocsWeb.ProcessLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation

  alias UserDocsWeb.StepLive.Header
  alias UserDocsWeb.StepLive.ShowComponent
  alias UserDocsWeb.StepLive.FormComponent

  @impl true
  def render(assigns) do
    ~L"""
    <div>
      <%= live_group(@socket, Header, ShowComponent, FormComponent,
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
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end
