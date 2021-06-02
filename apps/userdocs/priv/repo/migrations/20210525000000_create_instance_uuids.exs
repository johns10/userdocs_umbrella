defmodule UserDocs.Repo.Migrations.AddInstanceUUIDs do
  use Ecto.Migration

  def change do
    alter table(:step_instances) do
      add :uuid, :uuid
      add :process_instance_uuid, :uuid
    end
    alter table(:process_instances) do
      add :uuid, :uuid
      add :job_instance_uuid, :uuid
    end
    alter table(:job_instances) do
      add :uuid, :uuid
    end
    create index("step_instances", [:uuid])
    create index("process_instances", [:uuid])
    create index("job_instances", [:uuid])
  end
end
