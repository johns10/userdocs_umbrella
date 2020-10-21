defmodule UserDocs.Repo.Migrations.CreateAnnotations do
  use Ecto.Migration

  def change do
    create table(:annotations) do
      add :name, :string
      add :label, :string
      add :x_orientation, :string
      add :y_orientation, :string
      add :size, :integer
      add :color, :string
      add :thickness, :integer
      add :x_offset, :integer
      add :y_offset, :integer
      add :font_size, :integer
      add :font_color, :string

      add :annotation_type_id, references(:annotation_types, on_delete: :nothing)
      add :page_id, references(:pages, on_delete: :nothing)
      add :content_id, references(:content, on_delete: :nothing)
      add :content_version_id, references(:content, on_delete: :nothing)

      timestamps()
    end

    create index(:annotations, [:annotation_type_id])
    create index(:annotations, [:page_id])
    create index(:annotations, [:content_id])
  end
end
