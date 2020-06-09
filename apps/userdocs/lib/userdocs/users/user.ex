defmodule UserDocs.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  alias UserDocs.Users.Team

  schema "users" do
    pow_user_fields()

    many_to_many :teams, 
      Team, 
      join_through: Users.TeamUser, 
      on_replace: :delete
      
    timestamps()
  end
end
