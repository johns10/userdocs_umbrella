defmodule UserDocs.Automation.Step.Action do

  require Logger

  def validate_assoc(changeset) do
    Logger.debug("validate_assoc_action")
    changeset
    |> validate_action(:annotation)
    |> validate_action(:element)
  end

  defp validate_action(changeset, key) do
    Logger.debug("Validating action for #{key}")
    maybe_update_action(changeset, Ecto.Changeset.get_change(changeset, key, nil), key)
  end

  defp maybe_update_action(changeset, nil, _), do: changeset
  # This is the valid case, where there's no id, and the action is insert
  defp maybe_update_action(
    changeset, %{ action: :insert, data: %{ id: nil }} = nested_changeset, key
  ) do
    changeset
  end
  # This is the valid case, where there's an id, and the action is update
  defp maybe_update_action(
    changeset, %{ action: :update, data: %{ id: id }} = nested_changeset, key
  ) when is_integer(id) do
    changeset
  end
  defp maybe_update_action(
    changeset, %{ action: :update, data: %{ id: nil }} = nested_changeset, key
  ) do
    Logger.warn("Automation.update_step caught update action with nil id")
    update_nested_action(changeset, nested_changeset, key, :insert)
  end
  defp maybe_update_action(
    changeset, %{ action: :insert, data: %{ id: id }} = nested_changeset, key
  ) when is_integer(id) do
    Logger.warn("Automation.update_step caught insert action with integer id")
    update_nested_action(changeset, nested_changeset, key, :update)
  end

  defp update_nested_action(changeset, nested_changeset, key, action) do
    nested_changes = Map.put(nested_changeset, :action, action)
    changes = Map.put(changeset.changes, key, nested_changes)
    Map.put(changeset, :changes, changes)
  end

end
