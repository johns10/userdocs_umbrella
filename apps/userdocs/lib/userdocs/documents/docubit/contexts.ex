defmodule UserDocs.Documents.Docubit.Context do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Documents.Docubit, as: Docubit
  alias UserDocs.Documents.Docubit.Type
  alias UserDocs.Documents.Docubit.Context

  embedded_schema do
    field :settings, { :array, EctoKW }
  end

  # This function will apply the contexts in reverse order, overwriting each time.  It's the opposite of what
  # We have below (which might be incorrect on second thought)
  def context(docubit = %Docubit{}, parent_context = %Context{}) do
    with { :ok, context } <- update_context(parent_context, type_context(docubit)),
      { :ok, context } <- update_context(context, %{ settings: docubit.settings })
    do
      { :ok, context }
    else
      { :error, changeset }-> changeset
    end
  end

  def update_context(%Context{} = context, attrs \\ %{}) do
    context
    |> changeset(attrs)
    |> apply_action(:update)
  end

  defp changeset(context, attrs) do
    context
    |> cast(attrs, [ :settings ])
    |> apply_overwrite_policy(:settings)
  end

  defp apply_overwrite_policy(changeset, field) do
    case get_change(changeset, field) do # When there's a change to the field, do stuff, otherwise, return the changeset
      nil ->
        delete_change(changeset, field) # Because we apply in reverse order, changing to a nil value must be ignored
      "" -> changeset
      changes ->
        changes =
          Enum.reduce(changes, Map.get(changeset.data, field, []),
            fn({ key, value }, fields) -> # When there's a change, rip through the values and retreive each key from the existin fields
              case fields do # When the fields aren't there, we return the changeset, because we want to apply the changes as is
                nil -> changes
                _ ->
                  case Keyword.get(fields, key, :not_exist) do # This is the policy of the change.  Basically we overwrite everything because we apply in reverse order.e
                    nil -> Keyword.put(fields, key, value) # When the field is there but has a nil value, put the value from the changeset
                    :not_exist -> Keyword.put_new(fields, key, value) # When the field doesn't exist, put the value from the changeset
                    _ -> Keyword.put(fields, key, value) # When the field is there and has a value, put the value
                  end
              end
            end
          )
        put_change(changeset, field, changes)
    end
  end

  # Applies all Contexts to a docubit.  Takes a docubit, returns a
  # Docubit with parent, type, and local contexts applied to the
  # Docubit
  def apply_context_changes(docubit, parent_contexts) do
    docubit
    |> Docubit.preload_type()
    |> add_contexts(parent_contexts, :type)
  end


  # Adds a particular type of context by calling add_contexts with the
  # contexts, fetched from the appropriate place.  Controls the
  # Hierarchy of contexts
  defp add_contexts(docubit = %Docubit{}, parent_contexts, :type) do
    Logger.debug("Adding Contexts to docubit with parent_contexts: #{inspect(parent_contexts)}")
    docubit
    |> add_contexts(parent_contexts)
    |> add_contexts(type_context(docubit))
  end

  # Converts the kw list of
  defp add_contexts(docubit = %Docubit{}, contexts) when is_map(contexts) do
    Logger.debug("Adding contexts #{inspect(contexts)} to Docubit")

    changeset = Docubit.changeset(docubit, contexts)

    { :ok, docubit } =
      Ecto.Changeset.apply_action(changeset, :update)

    docubit
  end

  defp type_context(docubit) do
    docubit
    |> Map.get(:type_id)
    |> String.to_atom()
    |> (&(Kernel.apply(Type, &1, []))).()
    |> Map.get(:contexts)
  end
end
