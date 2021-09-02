defmodule UserDocs.Projects.Project do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Web.Strategy
  alias UserDocs.Web.Page
  alias UserDocs.Automation.Process

  alias UserDocs.Users.Team

  @derive {Jason.Encoder, only: [:default, :base_url, :name]}
  schema "projects" do
    field :default, :boolean
    field :base_url, :string
    field :name, :string

    belongs_to :team, Team
    belongs_to :strategy, Strategy

    has_many :pages, Page
    has_many :processes, Process

    timestamps()
  end

  @doc false
  def create_changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :base_url, :team_id, :strategy_id, :default])
    |> foreign_key_constraint(:team_id)
    |> validate_required([:name, :base_url])
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :base_url, :team_id, :strategy_id, :default])
    |> foreign_key_constraint(:team_id)
    |> validate_required([:name, :base_url])
  end

  def change_default_project(project, attrs) do
    project
    |> cast(attrs, [:default])
  end
end
