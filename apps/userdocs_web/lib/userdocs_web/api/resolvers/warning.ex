defmodule UserDocsWeb.API.Resolvers.Warning do

  def get_warning!(%{ warnings: nil }, _args, _resolution) do
    IO.puts("Get warnings call where the parent is unidentified, and errors is nil")
    { :ok, [] }
  end
  def get_warning!(%{ warnings: errors }, _args, _resolution) do
    IO.puts("Get warnings call where the parent is unidentified, and it has errors")
    { :ok, errors }
  end

end
