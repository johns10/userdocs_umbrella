defmodule UserDocs.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :filename, :string
      add :size, :integer
      add :content_type, :string
      add :hash, :string

      timestamps()
    end

  end
end
