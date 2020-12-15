defmodule UserDocs.Repo.Migrations.CreateLanguageCodes do
  use Ecto.Migration

  def change do
    create table(:language_codes) do
      add :name, :string

      timestamps()
    end

  end
end
