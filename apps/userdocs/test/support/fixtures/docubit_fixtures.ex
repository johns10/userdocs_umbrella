defmodule UserDocs.DocubitFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents.Docubit, as: Docubit

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
