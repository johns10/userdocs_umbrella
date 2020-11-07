defmodule UserDocs.Documents.Docubit.Type do
  use Ecto.Schema

  alias UserDocs.Documents.Docubit.Type

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "docubit_types" do
    field :name, :string
    field :contexts, {:map, {:array, EctoKW}}
    field :allowed_children, {:array, :string}
  end



  def types() do
    Enum.map(types_attrs(), fn(attrs) -> Kernel.struct(Type, attrs) end)
  end

  def types_attrs() do
    [
      container_attrs(),
      row_attrs(),
      column_attrs(),
      p_attrs(),
      %{
        name: "Ordered List",
        id: "ol",
        contexts: %{
          settings: [
            name_prefix: False
          ]
        }
      },
      %{
        name: "List Item",
        id: "li",
        contexts: %{
          settings: [
            li_value: None,
            name_prefix: False
          ]
        }
      },
      %{
        name: "Unordered List",
        id: "unordered_list",
        contexts: %{}
      },
      %{
        name: "Text Content",
        id: "text_content",
        contexts: %{}
      },
      %{
        name: "Image Content",
        id: "img",
        contexts: %{}
      }
    ]
  end

  def p(), do: Kernel.struct(Type, p_attrs())
  def p_attrs() do
    %{
      name: "Paragraph",
      id: "p",
      contexts: %{},
      allowed_children: [ ]
    }
  end

  def column(), do: Kernel.struct(Type, column_attrs())
  def column_attrs() do
  %{
    name: "Column",
    id: "column",
    contexts: %{},
    allowed_children: [ "ol", "ul", "p" ]
  }
  end

  def row(), do: Kernel.struct(Type, row_attrs())
  def row_attrs() do
    %{
      name: "Row",
      id: "row",
      contexts: %{},
      allowed_children: [ "column" ]
    }
  end

  def container(), do: Kernel.struct(Type, container_attrs())
  def container_attrs() do
    %{
      name: "Container",
      id: "container",
      contexts: %{},
      allowed_children: [ "row" ]
    }
  end

end
