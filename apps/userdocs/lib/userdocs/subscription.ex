defmodule UserDocs.Subscription do

  require Logger

  alias ProcessAdministratorWeb.Endpoint

  def broadcast({ status, result }, type, operation, endpoint \\ Endpoint) do
    Logger.debug("#{operation} broadcast triggered on #{type}")
    case status do
      :ok ->
        try do
          endpoint.broadcast(type, operation, result)
        rescue
          UndefinedFunctionError ->
            Logger.error("UndefinedFunctionError, Endpoint Unavailable.")
            { status, result }
          e -> raise(e)
        end
        { status, result }
      _ ->
        { status, result }
    end
  end
end
