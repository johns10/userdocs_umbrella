defmodule UserDocs.Web.Element do
  use Ecto.Schema
  import Ecto.Changeset
  alias UserDocs.Web.Page

  schema "elements" do
    field :name, :string
    field :strategy, :string
    field :selector, :string

    belongs_to :page, Page

    timestamps()
  end

  @doc false
  def changeset(element, attrs) do
    element
    |> cast(attrs, [:name, :strategy, :selector, :page_id])
    |> foreign_key_constraint(:page_id)
    |> validate_required([:name, :strategy, :selector])
  end

  def safe(element = %UserDocs.Web.Element{}, _handlers) do
    %{
      id: element.id,
      page_id: element.page_id,

      name: element.name,
      strategy: element.strategy,
      selector: element.selector
    }
  end
  def safe(_ , handlers), do: safe(%UserDocs.Web.Element{}, handlers)
end
