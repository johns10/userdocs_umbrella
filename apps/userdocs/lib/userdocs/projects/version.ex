defmodule UserDocs.Projects.Version do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web
  alias UserDocs.Automation

  schema "versions" do
    field :name, :string

    belongs_to :project, Project
    has_many :pages, Web.Page
    many_to_many :processes, Automation.Process, join_through: "version_processes"

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:name, :project_id])
    |> validate_required([:name])
  end
end
