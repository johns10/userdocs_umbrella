defmodule ProjectURLOverride do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  embedded_schema do
    field :url, :string
    field :project_id, :integer
  end

  def changeset(override, attrs) do
    override
    |> cast(attrs, [:project_id, :url])
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
end
