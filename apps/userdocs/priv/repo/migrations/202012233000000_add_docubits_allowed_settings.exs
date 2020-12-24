defmodule UserDocs.Repo.Migrations.AddDocubitAllowedSettings do
  use Ecto.Migration

  def change do
    alter table(:docubit_types) do
      add :allowed_settings, {:array, :string}
    end
  end
end
