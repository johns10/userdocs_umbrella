defmodule UserDocs.Documents.Docubit.Renderer do

  alias UserDocs.Documents.DocubitType
  alias UserDocs.Documents.Docubit, as: Docubit

  def apply(docubit = %Docubit{ docubit_type: %DocubitType{} }) do
    fetch_renderer(docubit.docubit_type.name)
  end

  defp fetch_renderer(type) do
    "Elixir.UserDocsWeb.DocubitLive.Renderers."
    <> String.capitalize(type)
    |> String.to_existing_atom()
  end

end
