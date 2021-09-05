defmodule UserDocsWeb.API.Resolvers.JobInstance do
  @moduledoc "API Handler for Job Instance Object"
  alias UserDocs.JobInstances
  alias UserDocs.Jobs
  alias UserDocs.Jobs.Job

  def get_job_instance!(%Job{last_job_instance: job_instance}, _args, _resolution) do
    {:ok, job_instance}
  end

  def create_job_instance(_parent, %{job_id: job_id} = args, %{context: %{current_user: current_user}}) do
    job = Jobs.get_job!(job_id, %{preloads: [steps: true, processes: true, last_job_instance: true]})
    {:ok, job_instance} = JobInstances.create_job_instance(job)

    "user:" <> to_string(current_user.id)
    |> UserDocsWeb.Endpoint.broadcast("create", job_instance)

    {:ok, job_instance}
  end

  def update_job_instance(_parent, %{id: id} = attrs, %{context: %{current_user: current_user}}) do
    {:ok, job_instance} =
      JobInstances.get_job_instance!(id)
      |> JobInstances.update_job_instance(attrs)

    "user:" <> to_string(current_user.id)
    |> UserDocsWeb.Endpoint.broadcast("update", job_instance)

    {:ok, job_instance}
  end
end
