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
      <div>
        <%= @expanded %>
        <%= @action %>
      </div>
      <%= for(object <- @process.steps) do %>
        <%= live_show(@socket, Header, ShowComponent, FormComponent,
          id: "step-"
            <> Integer.to_string(object.id)
            <> "-show",
          title: "Edit step",
          select_lists: @select_lists,
          type: :step,
          object: object,
          parent: @process,
          action: :edit,
          struct: %Automation.Step{}
        ) %>
      <% end %>
      <%= live_footer(@socket, FormComponent,
        type: :step,
        struct: %Automation.Step{},
        object: %{},
        parent: @process,
        parent_type: :process,
        id: "process-"
          <> Integer.to_string(@process.id) <> "-"
          <> "step"
          <> "-footer",
        title: "New step",
        hidden: "",
        select_lists: @select_lists,
        action: :new
      ) %>
    </div>

    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, false)
      |> assign(:footer_action, false)
    {:ok, socket}
  end
end
