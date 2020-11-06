defmodule EctoKW do
  use Ecto.Type
  def type, do: :map

  # Provide custom casting rules.
  # Cast strings into the URI struct to be used at runtime
  def cast(kw = { key, value }) when is_atom(key)  do
    { :ok, kw }
  end

  def load(kw), do: kw

  def dump(kw = { _, _ }), do: {:ok, kw}
  def dump(_), do: :error
end
