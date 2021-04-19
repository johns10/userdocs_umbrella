defmodule UserDocs.Users.Team do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.ChangesetHelpers
  alias UserDocs.Users
  alias UserDocs.Projects.Project
  alias UserDocs.Documents.LanguageCode
  alias UserDocs.Documents.Content
  alias UserDocs.Users.TeamUser
  alias UserDocs.Jobs.Job

  schema "teams" do
    field :name, :string

    embeds_one :default_project, Project

    belongs_to :default_language_code, LanguageCode
    has_many :projects, Project
    has_many :content, Content
    has_many :team_users, TeamUser
    has_one :job, Job

    field :aws_region, :string
    field :aws_bucket, :string
    field :aws_access_key_id, UserDocs.Encrypted.Binary
    field :aws_access_key_id_hash, Cloak.Ecto.SHA256
    field :aws_secret_access_key, UserDocs.Encrypted.Binary
    field :aws_secret_access_key_hash, Cloak.Ecto.SHA256

    many_to_many :users,
      Users.User,
      join_through: TeamUser,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [ :name, :default_language_code_id, :aws_bucket, :aws_region, :aws_access_key_id, :aws_secret_access_key ])
    |> cast_assoc(:team_users)
    |> cast_assoc(:projects)
    |> foreign_key_constraint(:default_language_code_id)
    |> handle_users(attrs)
    |> unique_constraint(:name)
    |> validate_required([:name])
    |> put_hashed_fields()
  end

  def change_default_project(changeset) do
    changeset
    |> cast_assoc(:projects, with: &Project.change_default_project/2)
    |> ChangesetHelpers.check_only_one_default(:projects)
  end

  defp put_hashed_fields(changeset) do
    changeset
    |> put_change(:aws_access_key_id_hash, get_field(changeset, :aws_access_key_id))
    |> put_change(:aws_secret_access_key_hash, get_field(changeset, :aws_secret_access_key))
  end

  @doc false
  defp handle_users(team, %{"users" => users}) do
    team
    |> put_assoc(:users, users)
  end
  defp handle_users(team, _), do: team

end
