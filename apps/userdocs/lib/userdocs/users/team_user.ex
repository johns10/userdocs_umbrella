defmodule UserDocs.Users.TeamUser do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Users.User
  alias UserDocs.Users.Team

  schema "team_users" do
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    field :default, :boolean
    belongs_to :team, Team
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(team_user, attrs) do
    team_user
    |> Map.put(:temp_id, (team_user.temp_id || attrs["temp_id"]))
    |> cast(attrs, [ :team_id, :user_id, :delete, :default ])
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:user_id)
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
