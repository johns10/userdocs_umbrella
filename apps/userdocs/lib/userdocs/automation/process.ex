defmodule UserDocs.Automation.Process do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step

  alias UserDocs.Projects
  alias UserDocs.Automation
  alias UserDocs.Web

  schema "processes" do
    field :name, :string

    has_many :steps, Step

    many_to_many :versions,
      Projects.Version,
      join_through: Automation.VersionProcess,
      on_replace: :delete,
      on_delete: :delete_all

    many_to_many :pages,
      Web.Page,
      join_through: Automation.PageProcess,
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(process, attrs) do
    process
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
