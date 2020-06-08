defmodule UserDocsWeb.StepLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Automation
  alias UserDocs.Automation.Step

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :steps, list_steps())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Step")
    |> assign(:step, Automation.get_step!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Step")
    |> assign(:step, %Step{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Steps")
    |> assign(:step, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    step = Automation.get_step!(id)
    {:ok, _} = Automation.delete_step(step)

    {:noreply, assign(socket, :steps, list_steps())}
  end

  defp list_steps do
    Automation.list_steps()
  end
end
