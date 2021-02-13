defmodule UserDocs.Documents.ContentVersion do
  alias UserDocs.Documents.Content
  alias UserDocs.Documents.LanguageCode
  alias UserDocs.Projects.Version

  use Ecto.Schema
  import Ecto.Changeset

  schema "content_versions" do
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    field :body, :string
    field :name, :string

    belongs_to :language_code, LanguageCode
    belongs_to :content, Content
    belongs_to :version, Version

    timestamps()
  end

  @doc false
  def changeset(content_version, attrs) do
    content_version
    |> cast(attrs, [:name, :body, :temp_id, :delete, :language_code_id, :content_id, :version_id])
    |> foreign_key_constraint(:content_id)
    |> foreign_key_constraint(:version_id)
    |> foreign_key_constraint(:language_code_id)
    |> validate_required([:language_code_id, :content_id, :version_id])
  end

  def safe(content_version, handlers) do
    UserDocs.Documents.ContentVersion.Safe.apply(content_version, handlers)
  end

  def add_content_version(state) do
    UserDocs.Documents.ContentVersion.ContentVersions.add_content_version(state)
  end

  def remove_content_version(state, remove_id) do
    UserDocs.Documents.ContentVersion.ContentVersions.remove_content_version(state, remove_id)
  end
end
