defmodule UserDocs.Automation.Step.Action do

  require Logger

  def validate(changeset) do
    IO.puts("Validating changeset action")
    Map.put(changeset, :action, action(changeset.data))
  end

  def validate_assoc(changeset) do
    changeset
    |> validate_nested_action(:annotation)
    |> validate_nested_action(:element)
  end

  defp validate_nested_action(changeset, key) do
    case Ecto.Changeset.get_change(changeset, key, nil) do
      nil -> changeset
      nested_changeset ->
        Ecto.Changeset.put_change(changeset, key, validate(nested_changeset))
    end
  end

  defp action(%{ id: nil }), do: :insert
  defp action(%{ id: id }) when is_integer(id), do: :update

end
