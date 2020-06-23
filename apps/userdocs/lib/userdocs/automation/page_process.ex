defmodule UserDocs.Automation.PageProcess do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Automation.Process
  alias UserDocs.Web.Page

  @primary_key false

  schema "page_processes" do
    belongs_to :process, Process
    belongs_to :page, Page

    timestamps()
  end

  @doc false
  def changeset(page_process, attrs) do
    page_process
    |> cast(attrs, [:page_id, :process_id])
    |> validate_required([:page_id, :process_id])
  end
end
