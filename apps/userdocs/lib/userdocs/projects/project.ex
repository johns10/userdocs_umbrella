defmodule UserDocs.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset
  alias UserDocs.Projects.Version

  schema "projects" do
    field :base_url, :string
    field :name, :string
    field :team_id, :id

    has_many :versions, Version

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :base_url])
    |> validate_required([:name, :base_url])
  end
end
