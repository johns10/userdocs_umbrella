defmodule UserDocs.Documents.DocubitType do
  use Ecto.Schema
  import Ecto.Changeset

  alias UserDocs.Documents.DocubitType
  alias UserDocs.Documents.DocubitSetting
  alias UserDocs.Documents.Docubit.Context
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
    field :context, EctoContext
    field :allowed_children, {:array, :string}
    field :allowed_settings, {:array, Ecto.Enum}, values: UserDocs.Documents.DocubitSetting.valid_settings()
    field :allowed_data, {:array, Ecto.Enum }, values: @valid_data

    has_many :docubits, Docubit
  end

  def changeset(docubit_type, attrs \\ %{}) do
    docubit_type
    |> cast(attrs, [ :name, :allowed_children, :allowed_data, :allowed_settings, :context ])
    |> validate_required([ :name, :allowed_children, :allowed_data ])
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
      context: %{
        settings: %{
          li_value: "",
          name_prefix: false
        }
      },
      allowed_settings: [ :li_value, :name_prefix ],
      allowed_children: [ "p", "info" ],
      allowed_data: [
        UserDocs.Automation.Step,
        UserDocs.Documents.Content,
        UserDocs.Web.Annotation
      ]
    }
  end

  def ul(), do: Kernel.struct(DocubitType, ul_attrs())
  def ul_attrs() do
    %{
      name: "ul",
      context: %{
        settings: %{
        }
      },
      allowed_settings: [],
      allowed_children: [ "li" ],
      allowed_data: [ None ]
    }
  end

  def ol(), do: Kernel.struct(DocubitType, ol_attrs())
  def ol_attrs() do
    %{
      name: "ol",
      context: %{
        settings: %{
          name_prefix: false
        }
      },
      allowed_settings: [
        :li_value,
        :name_prefix,
        :show_title
        ],
      allowed_children: [ "li" ],
      allowed_data: [ None ]
    }
  end

  def img(), do: Kernel.struct(DocubitType, img_attrs())
  def img_attrs() do
    %{
      name: "img",
      context: %{
        settings: %{ }
      },
      allowed_settings: [
        :img_border,
        :border_width,
        :border_color
      ],
      allowed_children: [],
      allowed_data: [
        UserDocs.Automation.Step,
        UserDocs.Media.File
      ]
    }
  end

  def p(), do: Kernel.struct(DocubitType, p_attrs())
  def p_attrs() do
    %{
      name: "p",
      context: %{
        settings: %{ }
      },
      allowed_settings: [
        :li_value,
        :name_prefix
        ],
      allowed_children: [],
      allowed_data: [
        UserDocs.Automation.Step,
        UserDocs.Documents.Content,
        UserDocs.Web.Annotation
      ]
    }
  end

  def column(), do: Kernel.struct(DocubitType, column_attrs())
  def column_attrs() do
  %{
    name: "column",
    context: %{
      settings: %{ }
    },
    allowed_settings: [ :li_value, :name_prefix ],
    allowed_children: [ "ol", "ul", "p", "img" ],
    allowed_data: [ None ]
  }
  end

  def row(), do: Kernel.struct(DocubitType, row_attrs())
  def row_attrs() do
    %{
      name: "row",
      context: %{
        settings: %{ }
      },
      allowed_settings: [ :li_value, :name_prefix ],
      allowed_children: [ "column" ],
      allowed_data: [ None ]
    }
  end

  def container(), do: Kernel.struct(DocubitType, container_attrs())
  def container_attrs() do
    %{
      name: "container",
      context: %{
        settings: %{ }
      },
      allowed_settings: [ :li_value, :name_prefix ],
      allowed_children: [ "row" ],
      allowed_data: [ None ]
    }
  end

  def info(), do: Kernel.struct(DocubitType, info_attrs())
  def info_attrs() do
    %{
      name: "info",
      context: %{
        settings: %{}
      },
      allowed_settings: [
        :show_title
      ],
      allowed_children: [ "p" ],
      allowed_data: [
        UserDocs.Documents.Content
      ]
    }
  end
end
