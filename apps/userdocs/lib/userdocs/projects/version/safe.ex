defmodule UserDocs.Projects.Version.Safe do
  @moduledoc """
  This module is responsible for converting project structs to string keys/sanitized so we can send over to the browser
  """
  alias UserDocs.Projects.Version

  def apply(step, handlers \\ %{})
  def apply(version = %Version{}, handlers) do
    base_safe(version)
    |> maybe_safe_project(handlers[:project], version.project, handlers)
  end
  def apply(nil, _), do: nil

  defp base_safe(version) do
    %{
      id: version.id,
      name: version.name
    }
  end

  defp maybe_safe_project(version, _, %Ecto.Association.NotLoaded{}, _), do: version
  defp maybe_safe_project(version, nil, _, _), do: version
  defp maybe_safe_project(version, handler, project, handlers) do
    Map.put(version, :project, handler.(project, handlers))
  end
end
