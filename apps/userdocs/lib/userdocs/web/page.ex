defmodule UserDocs.Web.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Version
  alias UserDocs.Automation.Process
  alias UserDocs.Web.Element

  schema "pages" do
    field :name, :string
    field :url, :string

    belongs_to :version, Version

    has_many :processes, Process
    has_many :elements, Element

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :url, :version_id])
    |> foreign_key_constraint(:version_id)
    |> validate_required([:url])
  end
end
