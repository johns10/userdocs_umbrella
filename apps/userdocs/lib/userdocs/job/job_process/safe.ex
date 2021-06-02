defmodule UserDocs.Jobs.JobProcess.Safe do

  def apply(job_process, handlers \\ %{})
  def apply(job_process = %UserDocs.Jobs.JobProcess{}, handlers) do
    base_safe(job_process)
    |> maybe_safe_process(handlers[:process], job_process.process, handlers)
  end
  def apply(nil, _), do: nil

  defp base_safe(job_process) do
    %{
      id: job_process.id,
      order: job_process.order
    }
  end

  defp maybe_safe_process(job_process, %Ecto.Association.NotLoaded{}, _, _), do: job_process
  defp maybe_safe_process(job_process, nil, _, _), do: job_process
  defp maybe_safe_process(job_process, handler, process, handlers) do
    Map.put(job_process, :process, handler.(process, handlers))
  end
end
