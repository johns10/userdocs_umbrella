defmodule UserDocs.Documents.Docubit.Type do
  use Ecto.Schema

  alias UserDocs.Documents.Docubit.Type

  @primary_key {:id, :binary_id, autogenerate: false}
  embedded_schema do
    field :name, :string
    field :contexts, {:map, {:array, EctoKW}}
    field :allowed_children, {:array, :string}
    field :allowed_data, {:array, :string}
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
      ol_attrs(),
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

  def ul(), do: Kernel.struct(Type, ul_attrs())
  def ul_attrs() do
    %{
      name: "Unordered List",
      id: "ul",
      contexts: %{
        settings: [
        ]
      }
    }
  end

  def ol(), do: Kernel.struct(Type, ol_attrs())
  def ol_attrs() do
    %{
      name: "Ordered List",
      id: "ol",
      contexts: %{
        settings: [
          name_prefix: False
        ]
      }
    }
  end

  def img(), do: Kernel.struct(Type, img_attrs())
  def img_attrs() do
    %{
      name: "Image",
      id: "img",
      contexts: %{},
      allowed_data: [
        UserDocs.Automation.Step,
        UserDocs.Media.File
      ]
    }
  end

  def p(), do: Kernel.struct(Type, p_attrs())
  def p_attrs() do
    %{
      name: "Paragraph",
      id: "p",
      contexts: %{},
      allowed_data: [
        UserDocs.Automation.Step,
        UserDocs.Documents.Content,
        UserDocs.Web.Annotation
      ]
    }
  end

  def column(), do: Kernel.struct(Type, column_attrs())
  def column_attrs() do
  %{
    name: "Column",
    id: "column",
    contexts: %{},
    allowed_children: [ "ol", "ul", "p", "img" ],
    allowed_data: []
  }
  end

  def row(), do: Kernel.struct(Type, row_attrs())
  def row_attrs() do
    %{
      name: "Row",
      id: "row",
      contexts: %{},
      allowed_children: [ "column" ],
      allowed_data: []
    }
  end

  def container(), do: Kernel.struct(Type, container_attrs())
  def container_attrs() do
    %{
      name: "Container",
      id: "container",
      contexts: %{},
      allowed_children: [ "row" ],
      allowed_data: []
    }
  end

end
