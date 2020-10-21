defmodule UserDocs.Documents.DocuBit.Renderers.Console do

  def row(_, content) do
    "s_r" <> content <> "e_r\n"
  end

  def column(_, content) do
    "s_c" <> content <> "e_c"
  end

  def text(docubit, content) do
    docubit.data.name
  end
end
