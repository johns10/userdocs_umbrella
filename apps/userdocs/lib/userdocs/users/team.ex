defmodule UserDocs.Users.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.ChangesetHelpers
  alias UserDocs.Users
  alias UserDocs.Projects.Project
  alias UserDocs.Documents.LanguageCode
  alias UserDocs.Documents.Content
  alias UserDocs.Users.TeamUser

  schema "teams" do
    field :name, :string

    embeds_one :default_project, Project

    belongs_to :default_language_code, LanguageCode
    has_many :projects, Project
    has_many :content, Content
    has_many :team_users, TeamUser

    many_to_many :users,
      Users.User,
      join_through: TeamUser,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [ :name, :default_language_code_id ])
    |> cast_assoc(:team_users)
    |> cast_assoc(:projects, with: &Project.change_default_project/2)
    |> foreign_key_constraint(:default_language_code_id)
    |> handle_users(attrs)
    |> validate_required([:name])
    |> ChangesetHelpers.check_only_one_default(:projects)
  end

"""
  # This one is called when a socket gets passed in that has the data
  def projects(team = %UserDocs.Users.Team{}, %{ projects: projects }) do
    projects(team.id, projects)
  end
  def projects(team_id, projects) when is_integer(team_id) do
    Enum.filter(projects, fn(p) -> p.team_id == team_id end)
  end
"""

  @doc false
  defp handle_users(team, %{"users" => users}) do
    team
    |> put_assoc(:users, users)
  end
  defp handle_users(team, _), do: team

end
