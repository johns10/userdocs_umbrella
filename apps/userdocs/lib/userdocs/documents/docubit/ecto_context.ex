defmodule EctoContext do
  use Ecto.Type
  alias UserDocs.Documents.Docubit.Context
  def type, do: :map

  # Provide custom casting rules.
  # Cast strings into the URI struct to be used at runtime
  def cast(context) when is_map(context) do
    #IO.puts("Casting Ecto context")
    { :ok, context }
  end

  # Loading data from the database

  # Loading data from the database
  def load(context = %{ "settings" => settings }) when is_map(context) and is_map(settings) do
    #IO.puts("Loading Ecto context #{inspect(context)}")
    settings =
      case EctoSettings.load(settings) do
        { :ok, settings } -> settings
        _ -> raise(RuntimeError, "Uncaught error in #{__MODULE__}.load")
      end
    {:ok, struct!(Context, %{ settings: settings })}
  end
  def load(context) do
    { :error, context }
  end

  # dumping data to the database
  def dump(context = %{ settings: settings }) when is_map(context) and is_map(settings) do
    #IO.inspect("Dumping contexts #{inspect(context)}")
    settings =
      case EctoSettings.dump(settings) do
        { :ok, settings } -> settings
        _ -> raise(RuntimeError, "Uncaught error in #{__MODULE__}.dump")
      end
    {:ok, %{ settings: settings }}
  end
  def dump(_) do
    #IO.inspect("Dumping ERROR")
    :error
  end
end
