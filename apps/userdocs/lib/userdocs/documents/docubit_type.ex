defmodule UserDocs.Documents.DocubitType do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Documents.Docubit.Type
  alias UserDocs.Documents.Docubit

  @valid_data [
    UserDocs.Automation.Step,
    UserDocs.Documents.Content,
    UserDocs.Web.Annotation,
    UserDocs.Media.File,
    None
  ]

  schema "docubit_types" do
    field :name, :string
    field :contexts, EctoContext
    field :allowed_children, {:array, :string}
    field :allowed_data, {:array, Ecto.Enum }, values: @valid_data

    has_many :docubits, Docubit
  end

  def changeset(docubit_type, attrs \\ %{}) do
    docubit_type
    |> cast(attrs, [ :name, :allowed_children, :allowed_data, :contexts ])
    |> validate_required([ :name, :allowed_children, :allowed_data ])
  end

  def types() do
    Enum.map(attrs(), fn(attrs) -> Kernel.struct(Type, attrs) end)
  end

  def attrs() do
    [
      container_attrs(),
      row_attrs(),
      column_attrs(),
      p_attrs(),
      ol_attrs(),
      img_attrs(),
      li_attrs(),
      ul_attrs()
    ]
  end

  def li_attrs() do
    %{
      name: "li",
      contexts: %{
        settings: %{
          li_value: None,
          name_prefix: False
        }
      },
      allowed_children: [],
      allowed_data: [ None ]
    }
  end

  def ul(), do: Kernel.struct(Type, ul_attrs())
  def ul_attrs() do
    %{
      name: "ul",
      contexts: %{
        settings: %{
        }
      },
      allowed_children: [],
      allowed_data: [ None ]
    }
  end

  def ol(), do: Kernel.struct(Type, ol_attrs())
  def ol_attrs() do
    %{
      name: "ol",
      contexts: %{
        settings: %{
          name_prefix: False
        }
      },
      allowed_children: [],
      allowed_data: [ None ]
    }
  end

  def img(), do: Kernel.struct(Type, img_attrs())
  def img_attrs() do
    %{
      name: "img",
      contexts: %{},
      allowed_children: [],
      allowed_data: [
        UserDocs.Automation.Step,
        UserDocs.Media.File
      ]
    }
  end

  def p(), do: Kernel.struct(Type, p_attrs())
  def p_attrs() do
    %{
      name: "p",
      contexts: %{},
      allowed_children: [],
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
    name: "column",
    contexts: %{},
    allowed_children: [ "ol", "ul", "p", "img" ],
    allowed_data: [ None ]
  }
  end

  def row(), do: Kernel.struct(Type, row_attrs())
  def row_attrs() do
    %{
      name: "row",
      contexts: %{},
      allowed_children: [ "column" ],
      allowed_data: [ None ]
    }
  end

  def container(), do: Kernel.struct(Type, container_attrs())
  def container_attrs() do
    %{
      name: "container",
      contexts: %{},
      allowed_children: [ "row" ],
      allowed_data: [ None ]
    }
  end

end
