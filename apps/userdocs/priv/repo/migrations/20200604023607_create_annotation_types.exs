defmodule UserDocs.Repo.Migrations.CreateAnnotationTypes do
  use Ecto.Migration

  def change do
    create table(:annotation_types) do
      add :name, :string

      timestamps()
    end

  end
end
