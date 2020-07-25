defmodule UserDocsWeb.StepLive.Header do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  @impl true
  def render(assigns) do
    element = current_element(assigns, assigns.object.element_id)
    step_type_name = if(assigns.object.step_type != nil) do
      assigns.object.step_type.name
    else
      "None"
    end
    ~L"""
    <p class="card-header-title" style="margin-bottom:0px;">
      <%= @object.name %>
    </p>
    <%= live_component(@socket, UserDocsWeb.StepLive.Runner, [
      id: "step-" <> Integer.to_string(@object.id) <> "-runner",
      object: @object,
      element: element,
      step_type_name: step_type_name
    ]) %>
    """
  end

  def current_element(_, nil) do
    %{selector: "", strategy: ""}
  end
  def current_element(assigns, element_id) do
    assigns.select_lists.available_elements
    |> Enum.filter(fn(e) -> e.id == element_id end)
    |> Enum.at(0)
  end
end
