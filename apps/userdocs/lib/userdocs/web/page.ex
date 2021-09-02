defmodule UserDocs.Web.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Project
  alias UserDocs.Web.Element
  alias UserDocs.Web.Annotation

  @derive {Jason.Encoder, only: [:id, :order, :name, :url]}
  schema "pages" do
    field :order, :integer
    field :name, :string
    field :url, :string

    belongs_to :project, Project

    has_many :elements, Element
    has_many :annotations, Annotation

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :url, :project_id])
    |> foreign_key_constraint(:project_id)
    |> validate_required([:url])
  end

  def fields_changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :url, :project_id])
    |> validate_required([:url])
  end

  def safe(page, handlers \\ %{})
  def safe(page = %UserDocs.Web.Page{}, handlers) do
    base_safe(page)
  end
  def safe(nil, _), do: nil
  def safe(page, _), do: raise(ArgumentError, "Web.Page.Safe failed because it got an invalid argument: #{inspect(page)}")

  def base_safe(page = %UserDocs.Web.Page{}) do
    %{
      id: page.id,
      order: page.order,
      url: page.url,
    }
  end
end
