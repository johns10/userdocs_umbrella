defmodule UserDocs.Users.User do
  @moduledoc """
  The User Module
  """
  use Ecto.Schema
  import Ecto.Changeset
  use Pow.Ecto.Schema
  use Pow.Extension.Ecto.Schema,
    extensions: [PowResetPassword, PowEmailConfirmation, PowInvitation]

  alias UserDocs.ChangesetHelpers
  alias UserDocs.Users.Team
  alias UserDocs.Users.TeamUser
  alias UserDocs.Projects.Project
  alias UserDocs.Users.Override

  @derive {Jason.Encoder, only: [:id, :email, :browser_session, :image_path, :user_data_dir_path, :default_team_id]}
  schema "users" do
    pow_user_fields()

    field :browser_session, :string
    field :image_path, :string
    field :user_data_dir_path, :string

    field :default_team_id, :integer
    embeds_one :default_team, Team

    field :selected_team_id, :integer
    embeds_one :selected_team, Team
    field :selected_project_id, :integer
    embeds_one :selected_project, Project

    embeds_many :overrides, Override, on_replace: :delete

    has_many :team_users, TeamUser

    many_to_many :teams,
      Team,
      join_through: TeamUser,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> cast(attrs, [:default_team_id, :selected_team_id, :selected_project_id])
  end

  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :invited_by_id])
  end

  def invite_changeset(user_or_changeset, attrs) do
    invited_by =
      case attrs do
        %{"invited_by_id" => invited_by_id} -> UserDocs.Users.get_user!(invited_by_id)
        %{invited_by_id: invited_by_id} -> UserDocs.Users.get_user!(invited_by_id)
        _ -> raise("invited_by not set, invitation fails")
      end
    user_or_changeset
    |> cast(attrs, [:email, :invited_by_id])
    |> pow_invite_changeset(invited_by, attrs)
  end

  def change_browser_session(user, attrs) do
    user
    |> cast(attrs, [:browser_session])
  end

  def signin_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
  end

  def test_fixture_changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
    |> cast(attrs, [:default_team_id, :selected_team_id, :selected_project_id, :email_confirmed_at])
  end

  def signup_changeset(user, attrs) do
    user
    |> pow_user_id_field_changeset(attrs)
    |> pow_password_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end

  def change_options(user, attrs) do
    user
    |> cast(attrs, [:default_team_id, :selected_team_id, :selected_project_id, :image_path, :user_data_dir_path])
    |> cast_assoc(:team_users)
    |> cast_embed(:overrides)
    |> ChangesetHelpers.check_only_one_default(:team_users)
  end

  def change_selections(user, attrs) do
    user
    |> cast(attrs, [:default_team_id, :selected_team_id, :selected_project_id])
  end

  def preload_teams(user = %UserDocs.Users.User{}, %{teams: teams, team_users: team_users}) do
    Map.put(user, :teams, teams(user.id, teams, team_users))
  end

  def teams(user = %UserDocs.Users.User{}, %{teams: teams, team_users: team_users}) do
    teams(user.id, teams, team_users)
  end
  def teams(user_id, teams, team_users) when is_integer(user_id) do
    _teams_users =
      Enum.filter(team_users, fn(tu) -> tu.user_id == user_id end)

    team_ids =
      Enum.map(team_users, fn(tu) -> Map.get(tu, :team_id) end)

    Enum.filter(teams, fn(t) -> t.id in team_ids end)
  end

  def preload_projects(user = %UserDocs.Users.User{teams: teams}, %{projects: projects}) do
    teams =
      Enum.map(teams,
        fn(t) ->
          Map.put(t, :projects, Enum.filter(projects, fn(p) -> p.team_id == t.id end))
        end)
    Map.put(user, :teams, teams)
  end
end
