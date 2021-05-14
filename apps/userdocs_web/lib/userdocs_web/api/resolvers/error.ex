defmodule UserDocsWeb.API.Resolvers.Error do

  def get_error!(%{ errors: nil }, _args, _resolution) do
    IO.puts("Get errors call where the parent is unidentified, and errors is nil")
    { :ok, [] }
  end
  def get_error!(%{ errors: errors }, _args, _resolution) do
    IO.puts("Get errors call where the parent is unidentified, and it has errors")
    { :ok, errors }
  end

end
