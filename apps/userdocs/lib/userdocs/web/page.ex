defmodule UserDocs.Web.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Version
  alias UserDocs.Web.Element
  alias UserDocs.Web.Annotation

  @derive {Jason.Encoder, only: [:order, :name, :url, :version, :elements, :annotations]}
  schema "pages" do
    field :order, :integer
    field :name, :string
    field :url, :string

    belongs_to :version, Version

    has_many :elements, Element
    has_many :annotations, Annotation

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:order, :name, :url, :version_id])
    |> foreign_key_constraint(:version_id)
    |> validate_required([:url])
  end
end
