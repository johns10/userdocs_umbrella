defmodule UserDocs.Documents.Editor do

  require Logger

  alias UserDocs.Documents.DocumentVersion

  def add_new_column_to_body(document_version, %{ row_count: row_count, column_count: _}
  ) when is_integer(row_count) do
    document_version
    |> document_version_body()
    |> row(row_count)
    |> add_column_to_row()
    |> document_version_replace_row()
  end

  def add_new_row_to_body(document_version, %{"row-count" => _}) do
    document_version
    |> document_version_body()
    |> rows()
    |> reverse_rows()
    |> add_new_row()
    |> reverse_rows()
    |> add_rows_to_body()
  end

  @spec add_item_to_document_version_column(DocumentVersion.t(), Integer, Integer, map, atom) :: DocumentVersion.t()
  def add_item_to_document_version_column(document_version, row_count, column_count, type, id) do
    IO.puts("Adding item to columns")
    document_version
    |> document_version_body()
    |> row(row_count)
    |> document_version_column(column_count)
    |> document_version_add_item_to_column(type, id)
    |> document_version_replace_column_in_row(row_count, column_count)
    |> document_version_replace_row()
  end

  @spec document_version_column({DocumentVersion.t, map}, Integer) :: {DocumentVersion.t(), map()}
  defp document_version_column({ document_version, row = %{ "type" => "row" } }, column_count) do
    { document_version, column(row, column_count) }
  end
  @spec column(map(), Integer) :: map()
  defp column(row = %{ "type" => "row" }, column_count) do
    row["children"]
    |> Enum.filter(fn(col) -> col["data"]["column_count"] == column_count end)
    |> Enum.at(0)
  end

  @spec document_version_add_item_to_column({DocumentVersion.t, map}, map, atom) :: {DocumentVersion.t, map}
  defp document_version_add_item_to_column({ document_version, column }, type, id) do
    { document_version, add_item_to_column(column, type, id) }
  end

  @spec document_version_replace_column_in_row({DocumentVersion.t, map}, Integer, Integer) :: {DocumentVersion.t, map}
  defp document_version_replace_column_in_row({ document_version, column}, row_count, column_count) do
    { document_version, row } =
      document_version
      |> document_version_body()
      |> row(row_count)

    { document_version, replace_column_in_row(row, column, column_count)}
  end
  defp replace_column_in_row(row, new_column, column_count) do
    IO.puts("Replace Column in row")
    children =
      Enum.reduce(row["children"], [],
        fn(column, acc) ->
          if column["data"]["column_count"] == column_count do
            [ new_column | acc ]
          else
            [ column | acc ]
          end
        end)
      |> Enum.reverse()

    Map.put(row, "children", children)
  end

  @spec add_item_to_column(map, map, atom) :: map
  defp add_item_to_column(column = %{ "type" => "column" }, type, id) do
    IO.puts("Adding #{type} item to column")
    item =
      default_empty_item()
      |> Map.put("data", %{"id" => id})
      |> Map.put("type", type)

    items =
      column["children"]
      |> Enum.reverse()
      |> List.insert_at(0, item)
      |> Enum.reverse()

    Map.put(column, "children", items)
  end

  defp document_version_body(document_version = %DocumentVersion{}) do
    { document_version, document_version.body }
  end

  defp row({ document_version, body }, row_count) do
    { document_version, row(body, row_count) }
  end
  defp row(%{ "type" => "container", "children" => children}, row_count) do
    children
    |> Enum.filter(fn(row) -> row["data"]["row_count"] == row_count end)
    |> Enum.at(0)
  end

  defp add_column_to_row({ document_version, row = %{ "children" => children} }) do
    reversed_children = Enum.reverse(children)
    { document_version, Map.put(row, "children", add_column(reversed_children)) }
  end
  defp add_column_to_row({ body, nil }) do
    Logger.warn("Add column to row got nil row")
    { body, nil }
  end


  defp add_column(
    [ add_column = %{ "data" => %{
        "column_count" => current_column_count,
        "row_count" => current_row_count}}
      | columns ]
  ) do
    new_column =
      add_column
      |> Map.put("type", "column")
      |> Kernel.put_in(["data", "column_count"], current_column_count)

    new_add_column =
      default_add_column()
      |> Kernel.put_in(["data", "row_count"], current_row_count)
      |> Kernel.put_in(["data", "column_count"], current_column_count + 1)

    Enum.reverse([ new_add_column, new_column | columns ])
  end

  defp document_version_replace_row({ document_version, row = %{"data" => %{ "row_count" => row_count}}}) do
    rows =
      document_version.body
      |> rows()
      |> replace_specified_row(row, row_count)

    body = Map.put(document_version.body, "children", rows)
    Map.put(document_version, :body, body)
  end
  defp document_version_replace_row({ document_version, nil }) do
    Logger.warn("Replace row got a nil row")
    document_version
  end

  def rows({ document_version, body }) do
    { document_version, rows(body) }
  end
  def rows(%{ "type" => "container", "children" => children}) do
    children
  end

  def reverse_rows({ document_version, rows }) do
    { document_version, Enum.reverse(rows)}
  end

  def add_new_row({document_version, rows}) do
    { document_version, add_new_row(rows) }
  end
  def add_new_row([ add_row = %{ "data" => %{"row_count" => current_row_count}} | rows ]) do

    new_empty_column =
      default_empty_column()
      |> Kernel.put_in(["data", "row_count"], current_row_count)

    new_add_column =
      default_add_column()
      |> Kernel.put_in(["data", "row_count"], current_row_count)
      |> Kernel.put_in(["data", "column_count"], 2)

    new_row =
      add_row
      |> Map.put("type", "row")
      |> Map.put("children", [ new_empty_column, new_add_column ])
      |> Kernel.put_in(["data", "row_count"], current_row_count)

    new_add_row =
      default_add_row()
      |> Kernel.put_in(["data", "row_count"], current_row_count + 1)

    [ new_add_row, new_row | rows ]
  end

  def add_rows_to_body({ document_version, rows }) do
    body = Map.put(document_version.body, "children", rows)
    Map.put(document_version, :body, body)
  end

  def replace_specified_row(rows, new_row, count) do
    Enum.reduce(rows, [],
      fn(row, acc) ->
        if row["data"]["row_count"] == count do
          [ new_row | acc ]
        else
          [ row | acc ]
        end
      end)
    |> Enum.reverse()
  end

  """
  def columns({ body, row }) do
    { body, columns(row) }
  end
  def columns(row) do
    row["children"]
  end
  """

  defp default_add_column() do
    %{
      "type" => "add_column",
      "children" => [],
      "data" => %{
        "column_count" => 0,
        "row_count" => 0
      }
    }
  end

  defp default_add_row() do
    %{
      "children" => [ default_add_column() ],
      "data" => %{ "row_count" => 0 },
      "type" => "add_row"
    }
  end

  defp default_empty_column() do
    %{
      "children" => [],
      "data" => %{"column_count" => 1, "row_count" => 0},
      "type" => "column"
    }
  end

  defp default_empty_item() do
    %{
      "children" => [],
      "data" => %{},
      "type" => ""
    }
  end
end
