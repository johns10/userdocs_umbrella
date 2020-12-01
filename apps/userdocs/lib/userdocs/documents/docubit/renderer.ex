defmodule UserDocs.Documents.Docubit.Renderer do

  alias UserDocs.Documents.Docubit, as: Docubit

  def apply(docubit = %Docubit{}) do
    fetch_renderer(docubit.type_id)
  end

  defp fetch_renderer(type_id) do
    IO.inspect(type_id)
    "Elixir.UserDocsWeb.DocubitLive.Renderers."
    <> String.capitalize(type_id)
    |> String.to_existing_atom()
  end

end
