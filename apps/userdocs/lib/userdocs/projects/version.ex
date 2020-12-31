defmodule UserDocs.Projects.Version do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.Page
  alias UserDocs.Web.Strategy
  alias UserDocs.Automation.Process
  alias UserDocs.Projects.Project

  @derive {Jason.Encoder, only: [:name, :project, :strategy, :pages, :processes]}
  schema "versions" do
    field :name, :string
    field :order, :integer

    belongs_to :project, Project
    belongs_to :strategy, Strategy

    has_many :pages, Page
    has_many :processes, Process

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:name, :order, :project_id, :strategy_id])
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:strategy_id)
    |> validate_required([:name])
  end

  def processes(version = %UserDocs.Projects.Version{}, processes) do
    processes(version.id, processes)
  end
  def processes(version_id, processes) when is_integer(version_id) do
    Enum.filter(processes, fn(p) -> p.version_id == version_id end)
  end
end
