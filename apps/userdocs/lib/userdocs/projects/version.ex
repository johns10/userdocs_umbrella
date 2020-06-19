defmodule UserDocs.Projects.Version do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web
  alias UserDocs.Automation
  alias UserDocs.Projects

  schema "versions" do
    field :name, :string

    belongs_to :project, Project
    has_many :pages, Web.Page

    many_to_many :processes,
      Automation.Process,
      join_through: Automation.VersionProcess,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:name, :project_id])
    |> validate_required([:name])
  end
end
