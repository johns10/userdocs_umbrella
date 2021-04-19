
defmodule UserDocs.Repo.Migrations.AddNonWaffleAWSFiles do
  use Ecto.Migration

  def change do
    alter table(:screenshots) do
      add :aws_screenshot, :string
      add :aws_provisional_screenshot, :string
      add :aws_diff_screenshot, :string
    end
  end
end
