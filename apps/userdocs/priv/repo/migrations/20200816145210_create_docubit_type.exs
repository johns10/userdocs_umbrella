defmodule UserDocs.Repo.Migrations.CreateDocubits do
  use Ecto.Migration

  def change do
    create table(:docubit_types) do
      add :name, :string
      add :allowed_data, {:array, :string}
      add :allowed_children, {:array, :string}
      add :contexts, :jsonb
    end

  end
end
