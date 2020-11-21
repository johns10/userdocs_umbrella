defmodule StateHandlersTest do
  use ExUnit.Case
  doctest StateHandlers

  describe "state_handlers" do
    alias UserDocs.Users.User
    alias UserDocs.UsersFixtures
    alias UserDocs.ProjectsFixtures

    test "StateHandlers.List" do
      user = UsersFixtures.user()
      state = %{ users: [user] }
      result = StateHandlers.list(state, User, [])
      assert result = [user]
    end

  end
end
