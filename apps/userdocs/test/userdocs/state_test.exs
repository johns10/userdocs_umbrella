defmodule UserDocs.StateTest do
  use UserDocs.DataCase

  alias UserDocs.Users

  describe "state" do
    alias UserDocs.Users.User
    alias UserDocs.UsersFixtures
    alias UserDocs.ProjectsFixtures
    alias UserDocs.StateFixtures
    alias UserDocs.State

    alias StateHandlers

    @state_opts [ data_type: :list, strategy: :by_type ]

    test "" do
      state_fixture = StateFixtures.state()
      user = Enum.at(state_fixture.data.users, 0)
      state = State.start_link(%{}, user.email |> String.to_atom())
      state = State.start_link(%{}, user.email |> String.to_atom())
    end

  end
end
