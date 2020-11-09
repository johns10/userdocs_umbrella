defmodule UserDocs.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Projects.Version
  alias UserDocs.Documents.Docubit.Type
  alias UserDocs.Documents.Docubit, as: Docubit

  schema "documents" do
    embeds_one :body, Docubit, on_replace: :delete
    field :name, :string
    field :title, :string

    belongs_to :version, Version

    timestamps()
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:name, :title, :version_id])
    |> body_is_container_docubit_if_empty()
    |> cast_embed(:body)
    |> foreign_key_constraint(:version_id)
    |> validate_required([:name, :title])
  end

  defp body_is_container_docubit_if_empty(changeset) do
    attrs =
      %{ type_id: "container", address: [0], type: Type.container_attrs() }

    case get_change(changeset, :body) do
      nil -> put_embed(changeset, :body, attrs)
      "" -> put_embed(changeset, :body, attrs)
        _ -> changeset
    end
  end

  def load(document) do

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
