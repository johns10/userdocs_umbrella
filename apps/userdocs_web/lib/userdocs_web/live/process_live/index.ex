defmodule UserDocsWeb.ProcessesLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Automation
  alias UserDocs.Automation.Process

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :processes, list_processes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Process")
    |> assign(:process, Automation.get_process!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Process")
    |> assign(:process, %Process{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Processes")
    |> assign(:process, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    process = Automation.get_process!(id)
    {:ok, _} = Automation.delete_process(process)

    {:noreply, assign(socket, :processes, list_processes())}
  end

  defp list_processes do
    Automation.list_processes()
  end
end
