defmodule UserDocsWeb.ArgLive.Index do
  use UserDocsWeb, :live_view

  alias UserDocs.Automation
  alias UserDocs.Automation.Arg

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :args, list_args())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Arg")
    |> assign(:arg, Automation.get_arg!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Arg")
    |> assign(:arg, %Arg{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Args")
    |> assign(:arg, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    arg = Automation.get_arg!(id)
    {:ok, _} = Automation.delete_arg(arg)

    {:noreply, assign(socket, :args, list_args())}
  end

  defp list_args do
    Automation.list_args()
  end
end
