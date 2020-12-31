defmodule UserDocs.Subscription do

  require Logger

  alias ProcessAdministratorWeb.Endpoint

  def broadcast({ status, result }, type, operation) do
    Logger.debug("#{operation} broadcast triggered on #{type}")
    case status do
      :ok ->
        try do
          Endpoint.broadcast(type, operation, result)
        rescue
          UndefinedFunctionError ->
            Logger.debug("UndefinedFunctionError, Endpoint Unavailable.")
            { status, result }
          e -> raise(e)
        end
        { status, result }
      _ ->
        { status, result }
    end
  end

  def handle_event(socket, "create" = event, payload, opts) do
    IO.puts("Handling Event")
    StateHandlers.create(socket, payload, opts)
  end
  def handle_event(socket, "update" = event, payload, opts) do
    IO.puts("Handling Update Event")
    StateHandlers.update(socket, payload, opts)
  end
  def handle_event(socket, "delete" = event, payload, opts) do
    IO.puts("Handling Event")
    StateHandlers.delete(socket, payload, opts)
  end
end
