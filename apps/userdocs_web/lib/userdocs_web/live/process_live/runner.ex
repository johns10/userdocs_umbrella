defmodule UserDocsWeb.ProcessLive.Runner do
  use UserDocsWeb, :live_component

  alias UserDocs.Automation.Runner

  @impl true
  def render(assigns) do
    ~L"""
    <a id="<%= @id %>"
      phx-click="execute-process"
      phx-value-id="<%= @process.id %>"
      phx-target="#automation-manager"
      phx-hook="executeProcess"
      status="<%= @status %>"
    >
      <span class="icon">
        <%= case @status do
          :ok -> content_tag(:i, "", [class: "fa fa-play-circle", aria_hidden: "true"])
          :failed -> content_tag(:i, "", [class: "fa fa-times", aria_hidden: "true"])
          :started -> content_tag(:i, "", [class: "fa fa-spinner", aria_hidden: "true"])
          :complete -> content_tag(:i, "", [class: "fa fa-check", aria_hidden: "true"])
        end %>
      </span>
    </a>
    """
  end

  def handle_event("update_process", %{ "status" => status } = payload, socket) do
    {
      :noreply,
      socket
      |> assign(:status, String.to_atom(status))
      |> assign(:errors, payload["errors"])
    }
  end

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:status, :ok)
      |> assign(:error, "")

    {:ok, socket}
  end
end
