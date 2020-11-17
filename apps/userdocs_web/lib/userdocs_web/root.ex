defmodule UserDocsWeb.Root do

  def handle_event("select_version", payload, socket) do

  end

  def handle_event(name, _payload, _socket) do
    raise(FunctionClauseError, "Event #{name} not implemented by Root")
  end
end
