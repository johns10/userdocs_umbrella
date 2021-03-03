defmodule UserDocs.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.ChangesetHelpers
  alias UserDocs.Projects.Version
  alias UserDocs.Documents.Document

  alias UserDocs.Users.Team

  schema "projects" do
    field :default, :boolean
    field :base_url, :string
    field :name, :string

    belongs_to :default_version, Version

    belongs_to :team, Team

    has_many :versions, Version
    has_many :documents, Document

    timestamps()
  end

  @doc false
  def create_changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :base_url, :team_id, :default_version_id, :default])
    |> foreign_key_constraint(:team_id)
    |> validate_required([:name, :base_url])
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :base_url, :team_id, :default_version_id, :default])
    |> cast_assoc(:versions, with: &Version.change_default_version/2)
    |> foreign_key_constraint(:team_id)
    |> validate_required([:name, :base_url])
    |> ChangesetHelpers.check_only_one_default(:versions)
  end

  def change_default_project(project, attrs) do
    project
    |> cast(attrs, [ :default ])
  end
end
