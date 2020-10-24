defmodule UserDocs.Web.AnnotationType do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:args, :name]}
  schema "annotation_types" do
    field :args, {:array, :string}
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(annotation_type, attrs) do
    annotation_type
    |> cast(attrs, [:name, :args])
    |> validate_required([:name])
  end

  def safe(annotation_type = %UserDocs.Web.AnnotationType{}, _handlers) do
    %{
      name: annotation_type.name
    }
  end
  def safe(nil, _handlers), do: nil
end
