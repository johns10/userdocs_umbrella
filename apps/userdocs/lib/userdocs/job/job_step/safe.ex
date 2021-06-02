defmodule UserDocs.Jobs.JobStep.Safe do

  def apply(job_step, handlers \\ %{})
  def apply(job_step = %UserDocs.Jobs.JobStep{}, handlers) do
    base_safe(job_step)
    |> maybe_safe_step(handlers[:step], job_step.step, handlers)
  end
  def apply(nil, _), do: nil

  defp base_safe(job_step) do
    %{
      id: job_step.id,
      order: job_step.order
    }
  end

  defp maybe_safe_step(job_step, %Ecto.Association.NotLoaded{}, _, _), do: job_step
  defp maybe_safe_step(job_step, nil, _, _), do: job_step
  defp maybe_safe_step(job_step, handler, step, handlers) do
    Map.put(job_step, :step, handler.(step, handlers))
  end
end
