defmodule UserDocsWeb.ProcessLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation

  alias UserDocsWeb.Layout
  alias UserDocsWeb.StepLive.ShowComponent
  alias UserDocsWeb.StepLive.FormComponent

  @impl true
  def render(assigns) do
    ~L"""
    <div class="card">
      <header class="card-header">
        <p class="card-header-title">
          <%= @object.name %>
        </p>
        <a class="card-header-icon" aria-label="more options">
          <span class="icon" phx-click="expand" phx-target="<%= @myself %>">
            <i class="fa fa-angle-down" aria-hidden="true"></i>
          </span>
        </a>
      </header>
      <div class="card-content <%= Layout.is_hidden?(assigns) %>">
      <%= live_group(@socket, ShowComponent, FormComponent,
        [
          title: "Steps",
          type: :step,
          parent_type: :process,
          struct: %Automation.Step{},
          objects: @object.steps,
          return_to: Routes.step_index_path(@socket, :index),
          id: "process-"
            <> Integer.to_string(@object.id)
            <> "-steps",
          parent: @object
        ]
      ) %>
      </div>
    </div>
    """
  end
end
