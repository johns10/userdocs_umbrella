defmodule Subscription.Handler do

  def apply( type, "create", object, state ) do
    { state, _data } = StateHandlers.create(state, type, object)
    state
  end
  def apply( type, "update", object, state ) do
    { state, _data } = StateHandlers.update(state, type, object)
    state
  end
  def apply( type, "delete", id, _object, state ) do
    { state, _data } = StateHandlers.delete(state, type, id)
    state
  end

end
