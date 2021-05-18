defmodule UserDocs.Jobs.Job.Safe do

  def apply(job, handlers \\ %{})
  def apply(job = %UserDocs.Jobs.Job{}, handlers) do
    base_safe(job)
    |> maybe_safe_job_steps(handlers[:job_step], job.job_steps, handlers)
    |> maybe_safe_job_processes(handlers[:job_process], job.job_processes, handlers)
  end
  def apply(nil, _), do: nil

  defp base_safe(process) do
    %{
      id: process.id,
      order: process.order,
      name: process.name
    }
  end

  defp maybe_safe_job_steps(job, %Ecto.Association.NotLoaded{}, _, _), do: job
  defp maybe_safe_job_steps(job, nil, _, _), do: job
  defp maybe_safe_job_steps(job, handler, job_steps, handlers) do
    job_steps = Enum.map(job_steps,
      fn(job_step) ->
        handler.(job_step, handlers)
      end)
    Map.put(job, :job_steps, job_steps)
  end

  defp maybe_safe_job_processes(job, %Ecto.Association.NotLoaded{}, _, _), do: job
  defp maybe_safe_job_processes(job, nil, _, _), do: job
  defp maybe_safe_job_processes(job, handler, job_processes, handlers) do
    job_processes = Enum.map(job_processes,
      fn(job_process) ->
        handler.(job_process, handlers)
      end)

    Map.put(job, :job_processes, job_processes)
  end
end
