defmodule UserDocs.Projects.Project do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.ChangesetHelpers
  alias UserDocs.Projects.Version

  alias UserDocs.Users.Team

  @derive {Jason.Encoder, only: [:default, :base_url, :name]}
  schema "projects" do
    field :default, :boolean
    field :base_url, :string
    field :name, :string

    belongs_to :default_version, Version

    belongs_to :team, Team

    has_many :versions, Version

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
    |> cast(attrs, [:default])
  end

  def safe(project, handlers \\ %{})
  def safe(project = %UserDocs.Projects.Project{}, _handlers) do
    base_safe(project)
  end
  def safe(nil, _), do: nil
  def safe(project, _), do: raise(ArgumentError, "Web.Page.Safe failed because it got an invalid argument: #{inspect(project)}")

  def base_safe(project = %UserDocs.Projects.Project{}) do
    %{
      id: project.id,
      name: project.name,
      base_url: project.base_url,
    }
  end
end
