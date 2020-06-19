defmodule UserDocs.Automation.PageProcess do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false

  schema "page_processes" do
    field :page_id, :integer
    field :process_id, :integer

    timestamps()
  end

  @doc false
  def changeset(page_process, attrs) do
    page_process
    |> cast(attrs, [:page_id, :process_id])
    |> validate_required([:page_id, :process_id])
  end
end
