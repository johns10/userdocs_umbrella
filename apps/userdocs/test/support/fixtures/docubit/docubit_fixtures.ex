defmodule UserDocs.DocubitFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents.Docubit, as: Docubit

  def column(), do: Kernel.struct(Docubit, docubit_attrs(:column))
  def row(), do: Kernel.struct(Docubit, docubit_attrs(:row))
  def ol(), do: Kernel.struct(Docubit, docubit_attrs(:ol))
  def container(), do: Kernel.struct(Docubit, docubit_attrs(:container))
  def p(), do: Kernel.struct(Docubit, docubit_attrs(:p))
  def img(), do: Kernel.struct(Docubit, docubit_attrs(:img))

  def docubit_attrs(:p) do
    %{
      type_id: "p",
    }
  end

  def docubit_attrs(:img) do
    %{
      type_id: "img",
    }
  end

  def docubit_attrs(:ol) do
    %{
      type_id: "ol",
    }
  end

  def docubit_attrs(:row) do
    %{
      type_id: "row"
    }
  end

  def docubit_attrs(:column) do
    %{
      type_id: "column"
    }
  end

  def docubit_attrs(:container) do
    %{
      type_id: "container",
      address: [0]
    }
  end

end
