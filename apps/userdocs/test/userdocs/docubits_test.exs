defmodule UserDocs.DocubitsTest do
  use UserDocs.DataCase

  alias UserDocs.Documents

  describe "docubits" do
    alias UserDocs.Documents.DocuBit

    @row_only UserDocs.Documents.DocuBit.test_docubit_row()
    @valid_docubit UserDocs.Documents.DocuBit.test_docubit_map()

    """
    def docubit_fixture(attrs \\ %{}) do
      DocuBit.parse(@valid_docubit)
    end

    def docubit_row(attrs \\ %{}) do
      DocuBit.parse(@row_only)
    end

    test "docubit_test" do
      docubit = docubit_fixture()
    end

    test "docubit_render" do
      docubit = docubit_fixture()
      opts = %{
        renderer: "Console",
      }
    end
    """
  end
end
