defmodule UserDocs.ChangeTracker do

  require Logger

  def execute(%{ current_object: current_object } = state, params, change_function) do
    # Run the params through the changeset function to get a change function
    current_changes =
      change_function.(current_object, params)
      |> Map.put(:action, :validate)

    Logger.debug("Handling changes #{inspect(current_changes.changes)}")

    """
    This one would run the new object through a changeset, but I'm not sure I want to
    { _status, new_object } =
      case Ecto.Changeset.apply_action(current_changes, :update) do
        { :ok, new_object } ->
          { :ok, new_object }
        { _, _ } ->
          # TODO: Fix, unconditionally update current object
          Logger.debug("Changeset invalid, failing to update current object.")
          { :nok, current_object }
      end

    Map.put(state, :current_object, new_object)
    """

    # Run the changes through the handle_changes function in the domain
    # This produces the changes
    state = apply(
      current_object.__meta__.schema,
      :handle_changes,
      [ current_changes.changes, state ]
    )
  end
end
