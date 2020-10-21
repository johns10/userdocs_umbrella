defmodule UserDocs.Repo.Migrations.CreateLanguageCodes do
  use Ecto.Migration

  def change do
    create table(:language_codes) do
      add :code, :string

      timestamps()
    end

  end
end
