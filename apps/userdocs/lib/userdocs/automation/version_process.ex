defmodule UserDocs.Automation.VersionProcess do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  
  schema "version_processes" do
    field :version_id, :id
    field :process_id, :id

    timestamps()
  end

  @doc false
  def changeset(version_process, attrs) do
    version_process
    |> cast(attrs, [])
    |> validate_required([])
  end
end
