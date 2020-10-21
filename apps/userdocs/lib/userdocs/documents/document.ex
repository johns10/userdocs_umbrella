defmodule UserDocs.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Version

  schema "documents" do
    field :body, :map
    field :name, :string
    field :title, :string

    belongs_to :version, Version

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:name, :title, :body, :version_id])
    |> foreign_key_constraint(:version_id)
    |> validate_required([:name, :title])
  end

  def default_body() do
    %{
      "children" => [
        %{
          "children" => [
            %{
              "children" => [
                %{
                  "children" => [],
                  "data" => %{"column_count" => 1, "row_count" => 1},
                  "type" => "div"
                }
              ],
              "data" => %{"column_count" => 1, "row_count" => 1},
              "type" => "column"
            },
            %{
              "children" => [],
              "data" => %{"column_count" => 2, "row_count" => 1},
              "type" => "add_column"
            }
          ],
          "data" => %{"row_count" => 1},
          "type" => "row"
        },
        %{"children" => [], "data" => %{"row_count" => 2}, "type" => "add_row"}
      ],
      "data" => %{},
      "type" => "container"
    }
  end
end
