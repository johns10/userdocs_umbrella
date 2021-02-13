defmodule UserDocsWeb.GroupComponent do
  use UserDocsWeb, :live_component
  use Phoenix.HTML

  @impl true
  def mount(socket) do
    {
      :ok,
      socket
      |> assign(:expanded, false)
      |> assign(:show_form, false)
      |> assign(:footer_action, :none)
    }
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  @impl true
  def handle_event("expand", _, socket) do
    socket = assign(socket, :expanded, not socket.assigns.expanded)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new", _, socket) do
    {
      :noreply,
      socket
      |> assign(:footer_action, :new)
    }
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :footer_action, :show)}
  end

  def show_form?(:new), do: ""
  def show_form?(_), do: " is-hidden"

  def is_expanded?(false), do: " is-hidden"
  def is_expanded?(true), do: ""
end
