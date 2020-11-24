defmodule UserDocsWeb.Defaults do
  def state_opts(type), do: Keyword.put(state_opts(), :type, type)
  def state_opts() do
    [ data_type: :list, strategy: :by_type, loader: &Phoenix.LiveView.assign/3 ]
  end
end
