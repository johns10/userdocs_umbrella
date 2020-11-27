defmodule UserDocsWeb.Defaults do
  def state_opts(type), do: Keyword.put(state_opts(), :type, type)
  def state_opts() do
    [ data_type: :list, strategy: :by_type, loader: &Phoenix.LiveView.assign/3 ]
  end

  def channel(socket) do
    "team-" <> Integer.to_string(socket.assigns.current_team_id)
  end
end
