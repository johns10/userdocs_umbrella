defmodule UserDocs.Documents.DocubitSetting do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @derive {Jason.Encoder, only: [:li_value, :name_prefix]}
  embedded_schema do
    field :li_value, :string
    field :name_prefix, :boolean
  end

  def changeset(docubit_type, attrs \\ %{}) do
    docubit_type
    |> cast(attrs, [ :li_value, :name_prefix ])
  end

  def valid_settings() do
    [
      :li_value,
      :name_prefix
    ]
  end

  #def li_value(), do: Kernel.struct(DocubitSetting, li_value_attrs())
  def li_value() do
    %{
      field_type: :select,
      select_options: [{ "False", false }, { "True", true }]
    }
  end

  #def name_prefix(), do: Kernel.struct(DocubitSetting, name_prefix_attrs())
  def name_prefix() do
    %{
      field_type: :select,
      select_options: [{ "False", false }, { "True", true }]
    }
  end

end
