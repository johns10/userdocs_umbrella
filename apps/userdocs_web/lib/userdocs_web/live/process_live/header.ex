defmodule UserDocsWeb.ProcessLive.Header do
  use UserDocsWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <p class="card-header-title">
      <%= @name %>
    </p>
    <%= live_component(@socket, UserDocsWeb.ProcessLive.Runner, [
      id: "process-" <> Integer.to_string(@object.id) <> "-runner",
      object: @object
    ]) %>
    """
  end
end
