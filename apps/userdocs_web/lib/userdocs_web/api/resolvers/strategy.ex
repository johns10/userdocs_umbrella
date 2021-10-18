defmodule UserDocsWeb.API.Resolvers.Strategy do

  alias UserDocs.Web.Strategy
  alias UserDocs.Elements.Element

  def get_strategy!(%Element{ strategy: %Strategy{} = strategy }, _args, _resolution) do
    IO.puts("Get strategy call where the parent is element, and it has a preloaded strategy")
    { :ok, strategy }
  end
  def get_strategy!(%Element{ strategy: nil, strategy_id: nil }, _args, _resolution) do
    IO.puts("Get strategy call where the parent is element, and the strategy_id is nil")
    { :ok, nil }
  end

end
