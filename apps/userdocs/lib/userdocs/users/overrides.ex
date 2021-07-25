defmodule UserDocs.Users.Override do
  @moduledoc """
    This object is used to override the URL of a project, and may be expanded to override other objects later
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:url, :project_id]}
  embedded_schema do
    field :temp_id, :string, virtual: true
    field :url, :string
    field :project_id, :integer
    field :delete, :boolean, virtual: true
  end

  def changeset(override, attrs) do
    override
    |> cast(attrs, [:id, :temp_id, :project_id, :url, :delete])
    |> maybe_mark_for_deletion()
    |> valid_project_id?()
  end

  def valid_project_id?(changeset) do
    case get_change(changeset, :project_id) do
      nil -> changeset
      project_id ->
        try do
          UserDocs.Projects.get_project!(project_id)
          changeset
        rescue
          Ecto.NoResultsError -> add_error(changeset, :project_id, "This project ID does exist. Pick a new project.")
        end
    end
  end

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
