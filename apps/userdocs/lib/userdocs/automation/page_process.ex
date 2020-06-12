defmodule UserDocs.Automation.PageProcess do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key false

  schema "page_processes" do
    field :page_id, :id
    field :process_id, :id

    timestamps()
  end

  @doc false
  def changeset(page_process, attrs) do
    page_process
    |> cast(attrs, [])
    |> validate_required([])
  end
end
