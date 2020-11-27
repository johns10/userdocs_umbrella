defmodule StateHandlers.Inspect do

  alias StateHandlers.Helpers

  def apply(state, opts) do
    state
    |> Helpers.maybe_access_assigns()
    |> Helpers.maybe_access_location(opts[:location])
    |> Helpers.unpack_state()
    |> inspect_state()

    state
  end

  def inspect_state(state) do
    log_string =
      Enum.reduce(state, "",
        fn({k, v}, log_string) ->
          log_string
          <> Atom.to_string(k)
          <> ": "
          <> Integer.to_string(Enum.count(v))
          <> "\n"
        end
      )
    IO.puts(log_string)
  end
end
