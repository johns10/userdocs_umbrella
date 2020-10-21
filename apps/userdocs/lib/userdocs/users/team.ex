defmodule UserDocs.Users.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Users
  alias UserDocs.Projects.Project

  schema "teams" do
    field :name, :string

    field :default_project_id, :integer
    many_to_many :users,
      Users.User,
      join_through: Users.TeamUser,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:name, :default_project_id])
    |> handle_users(attrs)
    |> validate_required([:name])
  end

  # This one is called when a socket gets passed in that has the data
  def projects(team = %UserDocs.Users.Team{}, %{ projects: projects }) do
    projects(team.id, projects)
  end
  def projects(team_id, projects) when is_integer(team_id) do
    Enum.filter(projects, fn(p) -> p.team_id == team_id end)
  end

  @doc false
  defp handle_users(team, %{"users" => users}) do
    team
    |> put_assoc(:users, users)
  end
  defp handle_users(team, _), do: team
end
