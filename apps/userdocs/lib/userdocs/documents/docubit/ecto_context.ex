defmodule EctoContext do
  use Ecto.Type
  def type, do: :jsonb

  # Provide custom casting rules.
  # Cast strings into the URI struct to be used at runtime
  def cast(context)  do
    #IO.puts("Casting Ecto context")
    { :ok, context }
  end

  # Loading data from the database

  # Loading data from the database
  def load(%{}), do: { :ok, %{} }
  def load(context) do
    #IO.puts("Loading context")
    context
  end

  # dumping data to the database
  def dump(%{ settings: settings }) when is_map(settings) do
    #IO.inspect("Dumping contexts")
    settings =
      Enum.reduce(settings, %{},
        fn({ k, v }, settings) when is_atom(k) and is_atom(v) ->
          Map.put(settings, Atom.to_string(k), Atom.to_string(v))
        end
      )
    {:ok, %{ settings: settings }}
  end
  def dump(%{}) do
    #IO.inspect("Dumping empty ap")
    {:ok, %{}}
  end
  def dump(_) do
    #IO.inspect("Dumping ERROR")
    :error
  end
end
