defmodule UserDocs.Subscription do

  require Logger

  alias UserDocsWeb.Endpoint

  def broadcast_children(object, changeset, opts) do
    Logger.debug("Broadcasting results from a " <> inspect(changeset.data.__struct__))
    actions = check_changes(changeset)
    queue = traverse_changes(object, actions)
    Enum.each(queue,
      fn({action, object}) ->
        opts = Keyword.put(opts, :action, Atom.to_string(action))
        StateHandlers.broadcast(%{}, object, opts)
      end
    )
  end

  def traverse_changes(object, actions) do
    Enum.reduce(actions, [],
      fn({key, %{action: action, changes: changes}}, acc) ->
        queue_change(action, Map.get(object, key), changes, acc)
      end
    )
  end

  def queue_change(_, object, _, acc) when object == %{}, do: acc
  def queue_change(action, object, changes, acc) do
    traverse_changes(object, changes) ++ [{action, object} | acc]
  end

  def check_changes(changeset) do
    schema = changeset.data.__struct__
    associations = changeset.data.__struct__.__schema__(:associations)
    # Logger.debug("Checking changes on #{schema} with associations #{inspect(associations)}")

    Enum.reduce(associations, %{},
      fn(association, acc) ->
        association_field = schema.__schema__(:association, association).field

        # Logger.debug("  Checking changes on #{association_field}")
        Ecto.Changeset.get_change(changeset, association_field)
        |> check_change(association_field, acc)
      end
    )
  end

  def check_change(nil, field, acc) do
    # Logger.debug("    No change detected")
    acc
  end
  def check_change(changeset, field, acc) do
    changes = check_changes(changeset)
    schema = changeset.data.__struct__
    # Logger.debug("    Change detected on #{schema}")

    attrs = %{
      action: changeset.action,
      changes: changes
    }

    Map.put(acc, field, attrs)
  end

  def broadcast({status, result}, type, operation) do
    Logger.debug("#{operation} broadcast triggered on #{type}")
    case status do
      :ok ->
        try do
          Endpoint.broadcast(type, operation, result)
        rescue
          UndefinedFunctionError ->
            Logger.debug("UndefinedFunctionError, Endpoint Unavailable.")
            {status, result}
          e -> raise(e)
        end
        {status, result}
      _ ->
        {status, result}
    end
  end

  def handle_event(socket, "create" = _event, payload, opts) do
    #Logger.debug("Handling Event")
    StateHandlers.create(socket, payload, opts)
  end
  def handle_event(socket, "update" = _event, payload, opts) do
    #Logger.debug("Handling Update Event")
    StateHandlers.update(socket, payload, opts)
  end
  def handle_event(socket, "delete" = _event, payload, opts) do
    #Logger.debug("Handling Event")
    StateHandlers.delete(socket, payload, opts)
  end
  def handle_event(socket, "upsert" = _event, payload, opts) do
    # Logger.debug("Handling upsert Event")
    StateHandlers.upsert(socket, payload, opts)
  end
end
