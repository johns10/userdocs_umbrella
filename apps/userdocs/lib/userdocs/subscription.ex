defmodule UserDocs.Subscription do

  require Logger

  alias UserDocsWeb.Endpoint

  def broadcast({ status, result }, type, operation) do
    Logger.debug("#{operation} broadcast triggered on #{type}")
    case status do
      :ok ->
        Endpoint.broadcast(type, operation, result)
        { status, result }
      _ ->
        { status, result }
    end
  end
end
