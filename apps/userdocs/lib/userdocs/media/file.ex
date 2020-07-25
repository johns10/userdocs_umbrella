defmodule UserDocs.Media.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :content_type, :string
    field :filename, :string
    field :hash, :string
    field :size, :integer

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :size, :content_type, :hash])
    |> validate_required([:filename, :size, :content_type, :hash])
  end
end
