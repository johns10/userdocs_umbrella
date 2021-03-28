defmodule UserDocs.Documents.Content do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Documents.ContentVersion
  alias UserDocs.Web.Annotation
  alias UserDocs.Users.Team

  schema "content" do
    field :name, :string
    field :title, :string

    belongs_to :team, Team

    has_many :annotation, Annotation
    has_many :content_versions, ContentVersion

    timestamps()
  end

  @doc false
  def changeset(content, attrs) do
    content
    |> cast(attrs, [:name, :title, :team_id])
    |> cast_assoc(:content_versions)
    |> foreign_key_constraint(:team_id)
    |> validate_required([:name, :team_id])
    |> case do
        %{valid?: false, changes: changes} = changeset when map_size(changes) == 1 and :erlang.is_map_key(:team_id, changes) ->
          %{changeset | action: :ignore}
        changeset ->
          changeset
      end
  end

  def safe(content, handlers \\ %{})
  def safe(content = %UserDocs.Documents.Content{}, handlers) do
    base_safe(content)
    |> maybe_safe_content_versions(handlers[:content_versions], content.content_versions, handlers)
  end
  def safe(nil, _), do: nil

  def base_safe(content = %UserDocs.Documents.Content{}) do
    %{
      id: content.id,
      name: content.name
    }
  end

  def maybe_safe_content_versions(content, nil, _, _), do: content
  def maybe_safe_content_versions(content, handler, content_versions, handlers) do
    safe_content_versions =
      Enum.map(content_versions, fn(cv) -> handler.(cv, handlers) end)
    Map.put(content, :content_versions, safe_content_versions)
  end
end
