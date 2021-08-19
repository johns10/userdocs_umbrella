defmodule UserDocsWeb.Plug.Integration do
  @moduledoc """
  Defines a plug to use with integration tests. Checks in and out a database connection for an external app.
  """
  use Plug.Router
  alias UserDocs.Repo
  alias UserDocs.TestDataset

  plug :match
  plug :dispatch

  defp checkout_shared_db_conn do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo, ownership_timeout: :infinity)
    :ok = Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  defp checkin_shared_db_conn(_) do
    :ok = Ecto.Adapters.SQL.Sandbox.checkin(Repo)
  end

  post "/db/checkout" do
    # If the agent is registered and alive, a db connection is checked out already
    # Otherwise, we spawn the agent and let it(!) check out the db connection
    owner_process = Process.whereis(:db_owner_agent)
    if owner_process && Process.alive?(owner_process) do
      send_resp(conn, 200, "connection has already been checked out")
    else
      {:ok, _pid} = Agent.start_link(&checkout_shared_db_conn/0, name: :db_owner_agent)
      send_resp(conn, 200, "checked out database connection")
    end
  end

  post "/db/checkin" do
    # If the agent is registered and alive, we check the connection back in
    # Otherwise, no connection has been checked out, we ignore this
    owner_process = Process.whereis(:db_owner_agent)
    if owner_process && Process.alive?(owner_process) do
      Agent.get(owner_process, &checkin_shared_db_conn/1)
      Agent.stop(owner_process)
      send_resp(conn, 200, "checked in database connection")
    else
      send_resp(conn, 200, "connection has already been checked back in")
    end
  end

  post "/db/factory" do
    UserDocs.TestDataset.create
    user = UserDocs.Users.list_users()
           |> Enum.filter(fn(u) -> u.email == "johns10davenport@gmail.com" end)
           |> Enum.at(0)
    processes = UserDocs.Automation.list_processes()
    process = processes |> Enum.at(0)
    steps = UserDocs.Automation.list_steps()
    step_types = UserDocs.Automation.list_step_types()
    screenshot_step_type_id = step_types |> Enum.filter(fn(st) -> st.name == "Full Screen Screenshot" end) |> Enum.at(0) |> Map.get(:id)
    response = %{
      user: user,
      step: steps |> Enum.at(0),
      full_screen_screenshot_step: steps |> Enum.filter(fn(s) -> s.step_type_id == screenshot_step_type_id end) |> Enum.at(0),
      failing_step: steps |> Enum.filter(fn(s) -> s.name == "Failure" end) |> Enum.at(0),
      process: process,
      failing_process: processes |> Enum.filter(fn(p) -> p.name == "Fail" end) |> Enum.at(0)
    }
    send_resp(conn, 200, Jason.encode!(response))
  end

  match _, do: send_resp(conn, 404, "not found")
end
