defmodule EctoSettings do
  use Ecto.Type
  alias UserDocs.Documents.DocubitSetting
  def type, do: :jsonb

  # Provide custom casting rules.
  # Cast strings into the URI struct to be used at runtime
  def cast(settings = %DocubitSetting{}) do
    #IO.puts("Casting Ecto settings")
    { :ok, settings }
  end
  def cast(settings) when is_map(settings)  do
    #IO.puts("Casting Ecto map settings")
    { :ok, settings }
  end

  # Loading data from the database

  # Loading data from the database
  def load(settings) when is_map(settings) do
    #IO.puts("Loading Settings #{inspect(settings)}")
    settings =
      Enum.reduce(settings, %{},
        fn({key, val}, acc) ->
          Map.put(acc, String.to_existing_atom(key), handle_value(val))
        end
      )
    {:ok, struct!(DocubitSetting, settings)}
  end
  def load(settings) do
    { :error, settings }
  end

  def handle_value(nil), do: nil
  def handle_value(value) when is_atom(value), do: Atom.to_string(value)
  def handle_value(value) when is_binary(value), do: value

  # dumping data to the database
  def dump(settings) when is_map(settings) do
    #IO.puts("Dumping settings")
    {:ok, settings}
  end
  def dump(_) do
    #IO.puts("Dumping ERROR")
    :error
  end
end
