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
      IO.inspect(assigns.opts)
      objects = assigns.opts[:objects]
      title = assigns.opts[:title]
      content_tag(:div, [class: "box"]) do
        content_tag(:div, [class: "media-content"]) do
          [
            content_tag(:strong, []) do
              title
            end,
            content_tag(:p, []) do
              for (object <- objects) do
                object.name
              end
            end
          ]
        end
      end
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
  