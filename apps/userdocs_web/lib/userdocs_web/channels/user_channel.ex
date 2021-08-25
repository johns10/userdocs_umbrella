defmodule UserDocsWeb.UserChannel do
  @moduledoc false
  use UserDocsWeb, :channel
  alias UserDocsWeb.Presence

  @impl true
  def join("user:" <> _user_id, %{"app" => app} = payload, socket) do
    #IO.puts("SOmeone's joining")
    if authorized?(payload) do
      send(self(), {:after_join, app})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end
  def handle_in("event:" <> event_name, payload, socket) do
    IO.inspect("socket:event:" <> event_name)
    broadcast!(socket, "event:" <> event_name, payload)
    {:noreply, socket}
  end
  def handle_in("command:" <> name, _payload, socket) do
    IO.inspect("socket:command" <> name)
    broadcast!(socket, "command:" <> name, %{})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:after_join, app}, socket) do
    {:ok, _} = Presence.track(socket, app, %{
      online_at: inspect(System.system_time(:second))
    })
    IO.puts("After Join hook")
    presence_list = Presence.list(socket)
    push(socket, "presence_state", presence_list)
    broadcast!(socket, "presence_state", presence_list)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
