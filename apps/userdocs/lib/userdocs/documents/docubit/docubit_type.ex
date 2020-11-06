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
      %{
        name: "Row",
        id: "row",

        contexts: %{}
      },
      %{
        name: "Column",
        id: "column",
        contexts: %{}
      },
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
        id: "image_content",
        contexts: %{}
      }
    ]
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
