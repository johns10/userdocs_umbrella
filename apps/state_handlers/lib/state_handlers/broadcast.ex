defmodule StateHandlers.Broadcast do

  require Logger

  def apply(_, _, nil), do: raise(RuntimeError, "Broadcast called with nil opts")
  def apply(state, data, opts) do
    opts =
      opts
      |> precheck_opt(:broadcast_function, opts[:broadcast_function])
      |> precheck_opt(:channel, opts[:channel])
      |> precheck_opt(:action, opts[:action])

    broadcast(data, opts[:broadcast], opts)

    state
  end

  def precheck_opt(opts, name, nil) do
    Logger.debug("Broadcast missing #{name} opt")
    Keyword.replace(opts, :broadcast, false)
  end
  def precheck_opt(opts, _, _), do: opts

  def broadcast(_, nil, _), do: ""
  def broadcast(_, False, _), do: ""
  def broadcast(data, _, opts) do
    broadcaster = opts[:broadcast_function]
    channel = opts[:channel]
    action =
      case opts[:action] do
        "create" -> "upsert"
        "update" -> "upsert"
        "insert" -> "create" # Do not like, but this all has to go soon anyways
        action -> action
      end
    broadcaster.(channel, action, data)
    if opts[:broadcast_associations] != false do
      handle_associations(channel, action, data, opts)
    end
  end

  def handle_associations(channel, action, [ _ | _ ] = data, opts) do
    Enum.each(data, fn(object) ->
      handle_associations(channel, action, object, opts)
      end
    )
  end
  def handle_associations(channel, action, data, opts) do
    Enum.each(associations(data), fn(association) ->
        handle_association(channel, action, Map.get(data, association), opts)
      end
    )
  end

  def handle_association(_, _, [], _) do
    ""
  end
  def handle_association(_, _, %Ecto.Association.NotLoaded{}, _) do
    ""
  end
  def handle_association(_, _, nil, _) do
    Logger.warn("Association Data nil")
  end
  def handle_association(channel, action, data, opts) do
    broadcaster = opts[:broadcast_function]
    case data do
      [ _ | _ ] -> broadcaster.(channel, action, %{ objects: data })
      data ->
        handle_associations(channel, action, data, opts)
        broadcaster.(channel, action, data)
    end

  end

  def associations(object), do: object.__meta__.schema.__schema__(:associations)

end
