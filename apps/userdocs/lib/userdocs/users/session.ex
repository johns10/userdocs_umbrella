defmodule UserDocs.Users.Session do
  use Ecto.Schema
  use Pow.Ecto.Schema
  import Ecto.Changeset


  schema "session" do
    pow_user_fields()
    field :user_opened_browser, :boolean
    field :browser_opened, :boolean
    field :navigation_drawer_closed, :boolean


    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> cast(attrs, [:default_team_id, :selected_team_id, :selected_project_id, :selected_version_id])
  end

end
