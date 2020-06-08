defmodule UserDocsWeb.StepTypeLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Automation
  alias UserDocs.Automation.StepType

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :step_types, list_step_types())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Step type")
    |> assign(:step_type, Automation.get_step_type!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Step type")
    |> assign(:step_type, %StepType{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Step types")
    |> assign(:step_type, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    step_type = Automation.get_step_type!(id)
    {:ok, _} = Automation.delete_step_type(step_type)

    {:noreply, assign(socket, :step_types, list_step_types())}
  end

  defp list_step_types do
    Automation.list_step_types()
  end
end
