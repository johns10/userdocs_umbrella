defmodule UserDocs.Users.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Users.User
  alias UserDocs.Users.Team

  schema "team_users" do
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    field :default, :boolean
    field :type, :string
    belongs_to :team, Team
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(team_user, attrs) do
    team_user
    |> Map.put(:temp_id, (team_user.temp_id || attrs["temp_id"]))
    |> cast(attrs, [:team_id, :user_id, :delete, :default, :type])
    |> cast_assoc(:user, with: &User.email_changeset/2)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id, name: :team_id_user_id_index)
    |> unique_constraint(:default, name: :user_id_default_index)
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset
  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
