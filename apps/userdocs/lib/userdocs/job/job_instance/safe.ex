defmodule UserDocs.JobInstances.JobInstance.Safe do

  alias UserDocs.Jobs.JobInstance

  def apply(step, handlers \\ %{})
  def apply(job_instance = %JobInstance{}, _handlers) do
    base_safe(job_instance)
  end
  def apply(nil, _), do: nil
  def apply(%Ecto.Association.NotLoaded{}, _), do: nil

  defp base_safe(job_instance) do
    Map.take(job_instance, JobInstance.__schema__(:fields))
  end
end
