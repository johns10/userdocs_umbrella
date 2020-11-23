defmodule StateHandlers.Create do

  alias StateHandlers.Helpers

  def apply(state, data, opts) when is_struct(data) do
    reload_opts = %{
      type: opts[:type], location: opts[:location],
      schema: data.__meta__.schema, strategy: opts[:strategy],
      loader: opts[:loader]
    }
    with schema <- data.__meta__.schema,
      assigns <- Helpers.maybe_access_assigns(state),
      location_data <- Helpers.maybe_access_location(assigns, opts[:location]),
      type <- Helpers.maybe_access_type(location_data, opts[:strategy], schema),
      data <- create(type, data, opts[:data_type]),
      state <- Helpers.reassign(state, location_data, data, reload_opts)
    do
      state
    end
  end

  def create(state, data, :list) do
    [ data | state ]
  end

  def get(_, _, _, opts), do: raise(RuntimeError, "State.Update failed to find a matching clause with options #{inspect(opts)}")

  def apply(_, _, opts), do: raise(RuntimeError, "State.Update.apply failed to find a matching clause with options #{inspect(opts)}")
end
