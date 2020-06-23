defmodule Subscription.Handler do

  def apply( type, "create" = command, object, state ) do
    { state, data } = StateHandlers.create(state, type, object)
    state
  end
  def apply( type, "update" = command, object, state ) do
    { state, data } = StateHandlers.update(state, type, object)
    state
  end
  def apply( type, "delete" = command, id, object, state ) do
    { state, data } = StateHandlers.delete(state, type, id)
    state
  end

end
