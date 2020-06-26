defmodule UserDocsWeb.PageLive.ShowComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation
  alias UserDocsWeb.ProcessLive.ShowComponent
  alias UserDocsWeb.ProcessLive.FormComponent


  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>">
      <p><%= @object.name %>: <%= @object.url %></p>
      <%= live_group(@socket, ShowComponent, FormComponent,
        [
          title: "Processes",
          type: :process,
          parent_type: :page,
          struct: %Automation.Process{},
          objects: @object.processes,
          return_to: Routes.process_index_path(@socket, :index),
          id: "page-"
            <> Integer.to_string(@object.id)
            <> "-processes",
          parent: @object
        ]
      ) %>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:expanded, false)
      |> assign(:action, :show)

      {:ok, socket}
  end
end
