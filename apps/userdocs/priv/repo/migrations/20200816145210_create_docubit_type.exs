defmodule UserDocs.Repo.Migrations.CreateDocubitTypes do
  use Ecto.Migration

  def change do
    create table(:docubit_types) do
      add :name, :string
      add :allowed_data, {:array, :string}
      add :allowed_children, {:array, :string}
      add :allowed_settings, {:array, :string}
      add :context, :map
    end

  end
end
