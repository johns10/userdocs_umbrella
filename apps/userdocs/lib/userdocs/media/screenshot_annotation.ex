defmodule UserDocs.Media.ScreenshotAnnotation do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Media.Screenshot
  alias UserDocs.Web.Annotation

  @primary_key false

  schema "document_annotations" do
    belongs_to :screenshot, Screenshot
    belongs_to :annotation, Annotation

    timestamps()
  end

  @doc false
  def changeset(screenshot_annotation, attrs) do
    screenshot_annotation
    |> cast(attrs, [:screenshot_id, :annotation_id])
    |> foreign_key_constraint(:screenshot_id)
    |> foreign_key_constraint(:annotation_id)
    |> validate_required([])
  end
end
