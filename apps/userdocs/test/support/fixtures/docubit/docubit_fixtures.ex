defmodule UserDocs.DocubitFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `UserDocs.Auth` context.
  """

  alias UserDocs.Documents.NewDocubit, as: Docubit

  def column(), do: Kernel.struct(Docubit, docubit_attrs(:column))
  def row(), do: Kernel.struct(Docubit, docubit_attrs(:row))
  def ol(), do: Kernel.struct(Docubit, docubit_attrs(:ol))
  def container(), do: Kernel.struct(Docubit, docubit_attrs(:container))

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
