defmodule UserDocs.Documents.Docubit.Context do
  use Ecto.Schema
  import Ecto.Changeset

  require Logger

  alias UserDocs.Documents.Docubit, as: Docubit
  alias UserDocs.Documents.Docubit.Context
  alias UserDocs.Documents.DocubitSetting, as: DocubitSettings

  @primary_key false
  embedded_schema do
    field :settings, EctoSettings
  end

  # This function will apply the context in reverse order, overwriting each time.  It's the opposite of what
  # We have below (which might be incorrect on second thought)
  def context(docubit = %Docubit{}, parent_context = %Context{}) do
    docubit.docubit_type.context
    |> handle_context_update(parent_context)
    |> handle_context_update(%Context{ settings: docubit.settings })
  end

  def handle_context_update(context, %Context{ settings: nil }), do: context
  def handle_context_update(context, attrs) do
    case update_context(context, attrs) do
      { :ok, context } -> context
      _ -> raise(RuntimeError, "#{__MODULE__}.handle_context_update failed")
    end
  end

  def update_context(context, attrs \\ %{}) do
  def update_context(%Context{} = context, %Context{} = attrs) do
    #IO.puts("Internal update_context")
    context
    |> internal_changeset(attrs)
    |> apply_action(:update)
  end
  def update_context(%Context{} = context, attrs) do
    #IO.puts("update_context")
    changeset = changeset(context, attrs)
    changeset =
      case get_change(changeset, :settings) do
        nil -> changeset
        "" -> changeset
        settings when map_size(settings) == 0 ->
          put_change(changeset, :settings, %DocubitSettings{})
        settings ->
          params =
            Map.take(settings, DocubitSettings.__schema__(:fields))

          { :ok, updated_settings } =
            current_settings_or_empty_settings(changeset.data.settings)
            |> DocubitSettings.ignore_nils_changeset(params)
    |> apply_action(:update)

          put_change(changeset, :settings, updated_settings)
  end

    apply_action(changeset, :update)
  end

  def current_settings_or_empty_settings(nil), do: %DocubitSettings{}
  def current_settings_or_empty_settings(settings), do: settings

  def create_context(attrs) do
    %Context{}
    |> changeset(attrs)
    |> apply_action(:update)
  end

  def changeset(context, attrs) do
    context
    |> cast(attrs, [ :settings ])
        end

  def internal_changeset(context, attrs) do
    #IO.puts("internal_changeset")
    context
    |> change()
    |> put_change(:settings, attrs.settings)
  end

  # Applies all context to a docubit.  Takes a docubit, returns a
  # Docubit with parent, type, and local context applied to the
  # Docubit
  def apply_context_changes(docubit, parent_context) do
    #IO.puts("Applying Context change to #{inspect(docubit.address)}")
    docubit
    |> apply_context_change(docubit.docubit_type.context)
    |> apply_context_change(parent_context)
    |> apply_context_change(%{ settings: docubit.settings })
  end

  defp apply_context_change(docubit = %Docubit{}, context = %Context{}) do
    apply_context_change(docubit, Map.take(context, Context.__schema__(:fields)))
  end
  defp apply_context_change(docubit = %Docubit{}, nil) do
    # Logger.debug("nil context, returning docubit")
    docubit
  end
  defp apply_context_change(docubit = %Docubit{}, %{settings: nil}), do: docubit
  defp apply_context_change(docubit = %Docubit{}, context_attrs) when is_map(context_attrs) do
    #Logger.debug("Adding context #{inspect(context_attrs)} to Docubit #{inspect(docubit)}")
    context = update_existing_context(docubit, context_attrs)
    update_docubit_context(docubit, context)
  end

  defp update_existing_context(docubit, context_attrs) do
    case update_context(docubit.context || %Context{}, context_attrs) do
      { :ok, context } -> context
      _ -> raise(RuntimeError, "#{__MODULE__}.existing_context failed to update context")
    end
  end

  defp update_docubit_context(docubit, context) do
    changeset = Docubit.changeset(docubit, %{ context: context })
    case Ecto.Changeset.apply_action(changeset, :update) do
      { :ok, docubit } -> docubit
      _ -> raise(RuntimeError, "#{__MODULE__}.update_docubit failed to update docubit")
    end
  end
end
