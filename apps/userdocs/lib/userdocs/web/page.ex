defmodule UserDocs.Web.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Version
  alias UserDocs.Web.Element
  alias UserDocs.Web.Annotation

  @derive {Jason.Encoder, only: [:id, :order, :name, :url]}
  schema "pages" do
    field :order, :integer
    field :name, :string
    field :url, :string

    belongs_to :version, Version

    has_many :elements, Element
    has_many :annotations, Annotation

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :url, :version_id])
    |> foreign_key_constraint(:version_id)
    |> validate_required([:url])
  end

  def fields_changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :url, :version_id])
    |> validate_required([:url])
  end

  def safe(page, handlers \\ %{})
  def safe(page = %UserDocs.Web.Page{}, handlers) do
    base_safe(page)
    |> maybe_safe_version(handlers[:version], page.version, handlers)
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

  defp maybe_safe_version(page, _, %Ecto.Association.NotLoaded{}, _), do: page
  defp maybe_safe_version(page, nil, _, _), do: page
  defp maybe_safe_version(page, handler, version, handlers) do
    Map.put(page, :version, handler.(version, handlers))
  end
end
