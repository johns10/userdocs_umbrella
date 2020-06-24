defmodule UserDocs.Web.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation

  schema "pages" do
    field :name, :string
    field :url, :string

    many_to_many :processes,
      Automation.Process,
      join_through: Automation.PageProcess

    belongs_to :version, UserDocs.Projects.Version

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:name, :url, :version_id])
    |> validate_required([:url])
  end
end
