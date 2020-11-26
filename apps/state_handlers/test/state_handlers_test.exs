defmodule StateHandlersTest do
  use UserDocs.DataCase

  describe "state_handlers" do
    alias UserDocs.Users.User
    alias UserDocs.UsersFixtures
    alias UserDocs.ProjectsFixtures


    test "StateHandlers.Load" do
      state_opts = [
        { [ data_type: :list, strategy: :by_type ], %{ users: %{} } },
        { [ data_type: :list, strategy: :by_type, location: :data ], %{ data: %{ users: %{}}} }
      ]
      Enum.each(state_opts,
        fn({opts, initial_state}) ->
          IO.puts("Running StateHandlers.Load with {inspect(opts)}")
          data = Enum.map(1..2, fn(_) -> UsersFixtures.user() end)
          state = StateHandlers.load(initial_state, data, User, opts)
          assert StateHandlers.list(state, User, opts) == data
        end
      )
    end

    test "StateHandlers.List" do
      user = UsersFixtures.user()
      state_opts = [
        { [ data_type: :list, strategy: :by_type ], %{ users: [user] } },
        { [ data_type: :list, strategy: :by_type, location: :data ], %{ data: %{ users: [user]}} }
      ]
      Enum.each(state_opts,
        fn({ opts, initial_state}) ->
          IO.puts("Running StateHandlers.List with #{inspect(opts)}")
          result = StateHandlers.list(initial_state, User, opts)
          assert result == [user]
        end
      )
    end

    test "StateHandlers.Get" do
      list_data = Enum.map(1..2, fn(_) -> UsersFixtures.user() end)
      state_opts = [
        { [ data_type: :list, strategy: :by_type ], %{ users: list_data } },
        { [ data_type: :list, strategy: :by_type, location: :data ], %{ data: %{ users: list_data}} }
      ]
      Enum.each(state_opts,
        fn({ opts, initial_state}) ->
          IO.puts("Running StateHandlers.Get with #{inspect(opts)}")
          id = list_data |> Enum.at(0) |> Map.get(:id)
          result = StateHandlers.get(initial_state, id, User, opts)
          assert result == list_data |> Enum.at(0)
        end
      )
    end

    test "StateHandlers.Create" do
      list_data = Enum.map(1..2, fn(_) -> UsersFixtures.user() end)
      state_opts = [
        { [ data_type: :list, strategy: :by_type ], %{ users: list_data } },
        { [ data_type: :list, strategy: :by_type, location: :data ], %{ data: %{ users: list_data}} }
      ]
      Enum.each(state_opts,
        fn({ opts, initial_state}) ->
          IO.puts("Running StateHandlers.Create with #{inspect(opts)}")
          user = UsersFixtures.user()
          result = StateHandlers.create(initial_state, user, opts)
          case { opts[:data_type], opts[:location] } do
            { :list, nil } -> assert result.users == [ user | initial_state.users]
            { :list, location } -> assert result[location][:users] == [ user | initial_state[location][:users]]
          end
        end
      )
    end

  end
end
