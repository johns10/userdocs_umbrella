defmodule UserDocs.DocubitFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents.Docubit, as: Docubit

  alias UserDocs.Documents
  alias UserDocs.Documents.Docubit.Type

  alias UserDocs.WebFixtures
  alias UserDocs.UsersFixtures
  alias UserDocs.AutomationFixtures
  alias UserDocs.DocumentVersionFixtures
  alias UserDocs.MediaFixtures

  def state() do
    document_version_attrs = %{ name: "test", title: "Test" }
    { :ok, document_version } = Documents.create_document_version(document_version_attrs)

    team = UsersFixtures.team()
    row = row(document_version.id)
    ol = ol(document_version.id)
    ol_type =
      Type.types()
      |> Enum.filter(fn(t) -> t.id == "ol" end)
      |> Enum.at(0)

    page = WebFixtures.page()
    badge_annotation_type = WebFixtures.annotation_type(:badge)
    outline_annotation_type = WebFixtures.annotation_type(:outline)

    content_one =
      DocumentVersionFixtures.content(team)

    content_two =
      DocumentVersionFixtures.content(team)

    content_three =
      DocumentVersionFixtures.content(team)

    file_one = MediaFixtures.file()
    file_two = MediaFixtures.file()
    file_three = MediaFixtures.file()
    file_four = MediaFixtures.file()

    annotation_one =
      WebFixtures.annotation(page)
      |> Map.put(:annotation_type_id, badge_annotation_type.id)
      |> Map.put(:annotation_type, badge_annotation_type)

    annotation_two =
      WebFixtures.annotation(page)
      |> Map.put(:annotation_type_id, outline_annotation_type.id)
      |> Map.put(:annotation_type, outline_annotation_type)

    strategy = WebFixtures.strategy()

    element_one =
      WebFixtures.element(page, strategy)
      |> Map.put(:strategy, strategy)

    element_two =
      WebFixtures.element(page, strategy)
      |> Map.put(:strategy, strategy)

    empty_step =
      AutomationFixtures.step()
      |> Map.put(:annotation, nil)
      |> Map.put(:element, nil)

    step_with_annotation =
      AutomationFixtures.step()
      |> Map.put(:annotation_id, annotation_one.id)
      |> Map.put(:annotation, annotation_one)
      |> Map.put(:element, nil)

    step_with_element =
      AutomationFixtures.step()
      |> Map.put(:element_id, element_two.id)
      |> Map.put(:element, element_two)
      |> Map.put(:annotation, nil)

    step_with_both =
      AutomationFixtures.step()
      |> Map.put(:element_id, element_two.id)
      |> Map.put(:element, element_two)
      |> Map.put(:annotation_id, annotation_one.id)
      |> Map.put(:annotation, annotation_one)

    %{
      document_version: document_version,
      ol: ol,
      ol_type: ol_type,
      row: row,
      state: %{
        data: %{
          files: [ file_one, file_two, file_three, file_four ],
          content: [ content_one, content_two, content_three ],
          steps: [empty_step, step_with_annotation, step_with_element, step_with_both],
          annotations: [ annotation_one, annotation_two ],
          elements: [ element_one, element_two ],
          strategies: [ strategy ],
          annotation_types: [badge_annotation_type, outline_annotation_type]
        }
      }
    }
  end

  def column(doc_id), do: Kernel.struct(Docubit, docubit_attrs(:column, doc_id))
  def row(doc_id), do: Kernel.struct(Docubit, docubit_attrs(:row, doc_id))
  def ol(doc_id), do: Kernel.struct(Docubit, docubit_attrs(:ol, doc_id))
  def container(doc_id), do: Kernel.struct(Docubit, docubit_attrs(:container, doc_id))
  def p(doc_id), do: Kernel.struct(Docubit, docubit_attrs(:p, doc_id))
  def img(doc_id), do: Kernel.struct(Docubit, docubit_attrs(:img, doc_id))

  def docubit_attrs(:p, document_version_id) do
    %{
      type_id: "p",
      document_version_id: document_version_id
    }
  end

  def docubit_attrs(:img, document_version_id) do
    %{
      type_id: "img",
      document_version_id: document_version_id
    }
  end

  def docubit_attrs(:ol, document_version_id) do
    %{
      type_id: "ol",
      document_version_id: document_version_id
    }
  end

  def docubit_attrs(:row, document_version_id) do
    %{
      type_id: "row",
      document_version_id: document_version_id
    }
  end

  def docubit_attrs(:column, document_version_id) do
    %{
      type_id: "column",
      document_version_id: document_version_id
    }
  end

  def docubit_attrs(:container, document_version_id) do
    %{
      type_id: "container",
      document_version_id: document_version_id
    }
  end

end
