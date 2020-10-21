defmodule UserDocs.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias UserDocs.Projects.Version

  alias UserDocs.Users.Team

  schema "projects" do
    field :base_url, :string
    field :name, :string

    field :default_version_id, :integer

    belongs_to :team, Team

    has_many :versions, Version

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :base_url,
      :team_id, :default_version_id])
    |> foreign_key_constraint(:team_id)
    |> validate_required([:name, :base_url])
  end
end
