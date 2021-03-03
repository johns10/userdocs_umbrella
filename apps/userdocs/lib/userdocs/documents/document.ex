defmodule UserDocs.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  alias  UserDocs.Documents.DocumentVersion
  alias  UserDocs.Projects.Project

  schema "documents" do
    field :name, :string
    field :title, :string
    belongs_to :project, Project
    has_many :document_versions, DocumentVersion

    timestamps()
  end

  @doc false
  def changeset(document_version, attrs) do
    document_version
    |> cast(attrs, [ :name, :title, :project_id ])
    |> foreign_key_constraint(:project_id)
    |> cast_assoc(:document_versions, with: &DocumentVersion.changeset/2)
    |> validate_required([:name, :title, :project_id])
  end
end
