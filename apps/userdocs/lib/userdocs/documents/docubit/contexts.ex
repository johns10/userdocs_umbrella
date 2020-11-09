defmodule UserDocs.Documents.Docubit.Context do

  require Logger

  alias UserDocs.Documents.Docubit, as: Docubit
  alias UserDocs.Documents.Docubit.Type

  # Applies all Contexts to a docubit.  Takes a docubit, returns a
  # Docubit with parent, type, and local contexts applied to the
  # Docubit
  def apply(docubit, parent_contexts) do
    docubit
    |> preload_type()
    |> add_contexts(parent_contexts, :type)
  end

  # Adds a particular type of context by calling add_contexts with the
  # contexts, fetched from the appropriate place.  Controls the
  # Hierarchy of contexts
  defp add_contexts(docubit = %Docubit{}, parent_contexts, :type) do
    Logger.debug("Adding Contexts to docubit with parent_contexts: #{inspect(parent_contexts)}")
    docubit
    |> add_contexts(parent_contexts)
    |> add_contexts(docubit.type.contexts)
  end
  # Converts the kw list of
  defp add_contexts(docubit = %Docubit{}, contexts) when is_map(contexts) do
    Logger.debug("Adding contexts #{inspect(contexts)} to Docubit")

    changeset = Docubit.changeset(docubit, contexts)

    { :ok, docubit } =
      Ecto.Changeset.apply_action(changeset, :update)

    docubit
  end

  defp preload_type(docubit) do
    docubit
    |> Map.put(:type, type(docubit))
  end

  defp type(docubit) do
    Type.types()
    |> Enum.filter(fn(t) -> t.id == docubit.type_id end)
    |> Enum.at(0)
  end
end
