defmodule UserDocs.Projects.Version do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.Page
  alias UserDocs.Projects.Project

  schema "versions" do
    field :name, :string

    belongs_to :project, Project

    has_many :pages, Page

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:name])
    |> foreign_key_constraint(:project_id)
    |> validate_required([:name])
  end
end
