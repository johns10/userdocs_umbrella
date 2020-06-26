defmodule UserDocs.Automation.Process do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Step
  alias UserDocs.Web.Page

  schema "processes" do
    field :name, :string

    belongs_to :page, Page

    has_many :steps, Step

    timestamps()
  end

  @doc false
  def changeset(process, attrs) do
    process
    |> cast(attrs, [:name, :page_id])
    |> foreign_key_constraint(:page_id)
    |> validate_required([:name])
  end
end
