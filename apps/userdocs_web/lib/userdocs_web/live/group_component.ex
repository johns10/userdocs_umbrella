defmodule UserDocsWeb.GroupComponent do
    use UserDocsWeb, :live_component
  
    @impl true
    def render(assigns) do
      #IO.puts("Rendering Group Component")
      #IO.inspect(assigns.test)
      #IO.inspect(assigns.title)
      ~L"""
        <%= body(assigns) %>
      """
    end

    def body(assigns) do
      IO.puts("Rendering Group Component")
      IO.inspect(assigns)
      [
        for (object <- assigns.objects) do
          object.name
        end
      ]
    end
  
    @impl true
    def mount(socket) do
      socket = assign(socket, :test, "Test Title")
      {:ok, socket}
    end

    @impl true
    def handle_event("close", _, socket) do
      {:noreply, push_patch(socket, to: socket.assigns.return_to)}
    end
  end
  