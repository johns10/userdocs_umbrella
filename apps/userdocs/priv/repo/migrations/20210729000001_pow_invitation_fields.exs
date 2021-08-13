defmodule UserDocs.Repo.Migrations.PowInivitationFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :invited_by_id, references(:users, on_delete: :nothing)
      add :invitation_token, :string
      add :invitation_accepted_at, :utc_datetime
    end
    create index(:users, [:invited_by_id])
  end

end
