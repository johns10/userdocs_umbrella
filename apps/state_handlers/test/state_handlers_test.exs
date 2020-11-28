defmodule StateHandlers.StateFixtures do

  alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.MediaFixtures
  alias UserDocs.WebFixtures
  alias UserDocs.AutomationFixtures
  alias UserDocs.ProjectsFixtures

  alias UserDocs.Users.User
  alias UserDocs.Users.TeamUser
  alias UserDocs.Users.Team
  alias UserDocs.Projects
  alias UserDocs.Projects.Project
  alias UserDocs.Projects.Version
  alias UserDocs.Documents
  alias UserDocs.Documents.Document
  alias UserDocs.Documents.DocumentVersion

  def state(opts) do
    opts =
      opts
      |> Keyword.put(:types, [ User, TeamUser, Team, Project, Version, Document, DocumentVersion ])

    user = UsersFixtures.user()
    team = UsersFixtures.team()
    team_user = UsersFixtures.team_user(user.id, team.id)
    project = ProjectsFixtures.project(team.id)
    v1 = ProjectsFixtures.version(project.id)
    v2 = ProjectsFixtures.version(project.id)
    document = DocumentFixtures.document(project.id)
    dv1 = DocumentFixtures.document_version(project.id, v1.id)
    dv2 = DocumentFixtures.document_version(project.id, v2.id)

    %{}
    |> StateHandlers.initialize(opts)
    |> StateHandlers.load([user], User, opts)
    |> StateHandlers.load([team], Team, opts)
    |> StateHandlers.load([team_user], TeamUser, opts)
    |> StateHandlers.load([project], Project, opts)
    |> StateHandlers.load([v1, v2], Version, opts)
    |> StateHandlers.load([document], Document, opts)
    |> StateHandlers.load([dv1, dv2], DocumentVersion, opts)
  end
end

defmodule StateHandlersTest do
  use UserDocs.DataCase

  describe "state_handlers" do
    alias UserDocs.Users.User
    alias UserDocs.Projects.Project
    alias UserDocs.Projects.Version
    alias UserDocs.UsersFixtures
    alias UserDocs.ProjectsFixtures
    alias UserDocs.DocumentVersionFixtures, as: DocumentFixtures
    alias StateHandlers.StateFixtures
    alias UserDocs.Documents.Document
    alias UserDocs.Documents.DocumentVersion

    test "StateHandlers.Initialize" do
      state_opts = [
        {
          [ data_type: :list, strategy: :by_type, types: [ User, Project, Version ] ],
          %{projects: [], users: [], versions: []}
        },
        {
          [ data_type: :list, strategy: :by_type, location: :data, types: [ User, Project, Version ] ],
          %{data: %{projects: [], users: [], versions: []}}
        }
      ]
      Enum.each(state_opts,
        fn({opts, result}) ->
          IO.puts("Running StateHandlers.Initialize with {inspect(opts)}")
          state = StateHandlers.initialize(%{}, opts)
          assert state == result
        end
      )
    end

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
          IO.puts("Running StateHandlers.List with {inspect(opts)}")
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
          IO.puts("Running StateHandlers.Get with {inspect(opts)}")
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
          IO.puts("Running StateHandlers.Create with {inspect(opts)}")
          user = UsersFixtures.user()
          result = StateHandlers.create(initial_state, user, opts)
          case { opts[:data_type], opts[:location] } do
            { :list, nil } -> assert result.users == [ user | initial_state.users]
            { :list, location } -> assert result[location][:users] == [ user | initial_state[location][:users]]
          end
        end
      )
    end


    test "StateHandlers.delete" do
      list_data = Enum.map(1..3, fn(_) -> UsersFixtures.user() end)
      state_opts = [
        { [ data_type: :list, strategy: :by_type ], %{ users: list_data } },
        { [ data_type: :list, strategy: :by_type, location: :data ], %{ data: %{ users: list_data}} }
      ]
      Enum.each(state_opts,
        fn({ opts, initial_state}) ->
          IO.puts("Running StateHandlers.Create with {inspect(opts)}")
          users = StateHandlers.list(initial_state, User, opts)
          [ user | expected_result ] = users
          state = StateHandlers.delete(initial_state, user, opts)
          assert StateHandlers.list(state, User, opts) == expected_result
        end
      )
    end

    test "StateHandlers.Preload loads has_many relationships" do
      opts = [ data_type: :list, strategy: :by_type, location: :data, preloads: [ :document_versions ] ]
      state = StateFixtures.state(opts)
      data = StateHandlers.list(state, Document, opts)
      test = StateHandlers.preload(state, data, opts[:preloads], opts)
    end

    test "StateHandlers.Preload loads BelongsTo has_one relationships" do
      opts = [ data_type: :list, strategy: :by_type, location: :data, preloads: [ :version ] ]
      state = StateFixtures.state(opts)
      data = StateHandlers.list(state, DocumentVersion, opts)
      result = StateHandlers.preload(state, data, opts[:preloads], opts)
      expected_result = StateHandlers.list(state, Version, opts) |> Enum.at(0)
      assert expected_result == result |> Enum.at(0) |> Map.get(:version)
    end

    test "StateHandlers.Preload loads and filters has_many relationships" do
      opts = [ data_type: :list, strategy: :by_type, location: :data, preloads: [ :document_versions ] ]
      state = StateFixtures.state(opts)
      project_id = StateHandlers.list(state, Project, opts) |> Enum.at(0) |> Map.get(:id)
      data = StateHandlers.list(state, Document, Keyword.put(opts, :filter, { :project_id, project_id }))
      expected_result = StateHandlers.list(state, DocumentVersion, opts)
      result = StateHandlers.preload(state, data, opts[:preloads], opts)
      assert result |> Enum.at(0) |> Map.get(:document_versions) == expected_result
    end
  end
end
