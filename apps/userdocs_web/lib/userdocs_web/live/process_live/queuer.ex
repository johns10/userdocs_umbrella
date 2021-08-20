defmodule UserDocsWeb.ProcessLive.Queuer do
  @moduledoc false
  use UserDocsWeb, :live_component

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:class, "")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <a id="<%= @id %>"
      phx-click="create-job-process"
      phx-value-id="<%= @process.id %>"
      phx-value-name="<%= @process.name %>"
      phx-target="#automation-manager"
      class="<%= @class %>"
    >
      <span class="icon">
        <%= content_tag(:i, "", [class: "fa fa-plus", aria_hidden: "true"]) %>
      </span>
    </a>
    """
  end
end
