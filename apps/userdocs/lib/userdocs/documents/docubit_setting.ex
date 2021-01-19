defmodule UserDocs.Documents.DocubitSetting do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :li_value,
    :name_prefix,
    :show_title,
    :img_border,
    :border_width,
    :border_color
  ]


  @primary_key false
  @derive {Jason.Encoder, only: @fields}
  embedded_schema do
    field :li_value, :string
    field :name_prefix, :boolean
    field :show_title, :boolean
    field :img_border, :boolean
    field :border_width, :integer
    field :border_color, :string
  end

  def changeset(docubit_type, attrs \\ %{}) do
    docubit_type
    |> cast(attrs, @fields)
  end

  def valid_settings() do
    @fields
  end

  #def li_value(), do: Kernel.struct(DocubitSetting, li_value_attrs())
  def li_value() do
    %{
      field_type: :select,
      select_options: [{"None", nil}, { "False", false }, { "True", true }]
    }
  end

  #def name_prefix(), do: Kernel.struct(DocubitSetting, name_prefix_attrs())
  def name_prefix() do
    %{
      field_type: :select,
      select_options: [{"None", nil}, { "False", false }, { "True", true }]
    }
  end

  #def name_prefix(), do: Kernel.struct(DocubitSetting, name_prefix_attrs())
  def show_title() do
    %{
      field_type: :select,
      select_options: [{"None", nil}, { "False", false }, { "True", true }]
    }
  end

  #def name_prefix(), do: Kernel.struct(DocubitSetting, name_prefix_attrs())
  def img_border() do
    %{
      field_type: :select,
      select_options: [{"None", nil}, { "False", false }, { "True", true }]
    }
  end

  #def name_prefix(), do: Kernel.struct(DocubitSetting, name_prefix_attrs())
  def border_width() do
    %{
      field_type: :number_input,
      select_options: []
    }
  end

  #def name_prefix(), do: Kernel.struct(DocubitSetting, name_prefix_attrs())
  def border_color() do
    %{
      field_type: :text_input,
      select_options: []
    }
  end

end
