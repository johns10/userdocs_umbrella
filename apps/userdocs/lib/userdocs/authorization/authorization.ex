defmodule UserDocs.Authorization do
  alias UserDocs.Repo
  alias UserDocs.Users.TeamUser
  import Ecto.Query, warn: false

  def check(object, %{ current_user: %{ id: current_user_id } }, do: action) do
    if Mix.env == :prod do
      case allowed?(object, current_user_id) do
        true -> action.()
        false -> { :error, "Not Allowed" }
      end
    else
      action.()
    end
  end
  def check(_, _), do: { :error, "Not Authenticated" }

  def allowed?(%UserDocs.Media.Screenshot{ id: id }, user_id) do
    list_screenshot_team_users(id)
    |> Enum.map(fn(tu) -> tu.user_id end)
    |> Enum.member?(user_id)
  end
  def allowed?(%UserDocs.Automation.Step{ id: id }, user_id) do
    list_step_team_users(id)
    |> Enum.map(fn(tu) -> tu.user_id end)
    |> Enum.member?(user_id)
  end
  def allowed?(%UserDocs.Jobs.Job{ id: id }, user_id) do
    list_job_team_users(id)
    |> Enum.map(fn(tu) -> tu.user_id end)
    |> Enum.member?(user_id)
  end
  def allowed?(step_instance_id, user_id) do
    list_step_instance_team_users(step_instance_id)
    |> Enum.map(fn(tu) -> tu.user_id end)
    |> Enum.member?(user_id)
  end

  def list_step_instance_team_users(id) do
    from(t in TeamUser, as: :team_users)
    |> join(:left, [team_users: tu], t in assoc(tu, :team), as: :teams)
    |> join(:left, [teams: t], p in assoc(t, :projects), as: :projects)
    |> join(:left, [projects: p], v in assoc(p, :versions), as: :versions)
    |> join(:left, [versions: v], p in assoc(v, :processes), as: :processes)
    |> join(:left, [processes: p], s in assoc(p, :steps), as: :steps)
    |> join(:left, [steps: s], si in assoc(s, :step_instances), as: :step_instance)
    |> where([step_instance: si], si.id == ^id)
    |> Repo.all()
  end

  def list_step_team_users(id) do
    from(t in TeamUser, as: :team_users)
    |> join(:left, [team_users: tu], t in assoc(tu, :team), as: :teams)
    |> join(:left, [teams: t], p in assoc(t, :projects), as: :projects)
    |> join(:left, [projects: p], v in assoc(p, :versions), as: :versions)
    |> join(:left, [versions: v], p in assoc(v, :processes), as: :processes)
    |> join(:left, [processes: p], s in assoc(p, :steps), as: :steps)
    |> where([steps: s], s.id == ^id)
    |> Repo.all()
  end

  def list_screenshot_team_users(id) do
    from(t in TeamUser, as: :team_users)
    |> join(:left, [team_users: tu], t in assoc(tu, :team), as: :teams)
    |> join(:left, [teams: t], p in assoc(t, :projects), as: :projects)
    |> join(:left, [projects: p], v in assoc(p, :versions), as: :versions)
    |> join(:left, [versions: v], p in assoc(v, :processes), as: :processes)
    |> join(:left, [processes: p], s in assoc(p, :steps), as: :steps)
    |> join(:left, [steps: s], si in assoc(s, :screenshot), as: :screenshot)
    |> where([screenshot: s], s.id == ^id)
    |> Repo.all()
  end

  def list_job_team_users(id) do
    from(t in TeamUser, as: :team_users)
    |> join(:left, [team_users: tu], t in assoc(tu, :team), as: :teams)
    |> join(:left, [teams: t], p in assoc(t, :jobs), as: :job)
    |> where([job: j], j.id == ^id)
    |> Repo.all()
  end
end
