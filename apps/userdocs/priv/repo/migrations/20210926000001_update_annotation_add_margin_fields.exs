
defmodule UserDocs.Repo.Migrations.AlterStepAddMarginFields do
  use Ecto.Migration

  def change do
    alter table(:steps) do
      add :margin_all, :integer, default: 0
      add :margin_top, :integer, default: 0
      add :margin_bottom, :integer, default: 0
      add :margin_left, :integer, default: 0
      add :margin_right, :integer, default: 0
    end
  end
end
