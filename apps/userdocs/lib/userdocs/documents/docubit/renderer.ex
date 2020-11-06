defmodule UserDocs.Documents.Docubit.Renderer do

  alias UserDocs.Documents.NewDocubit, as: Docubit

  def apply(docubit = %Docubit{}) do
    Map.put(docubit, :renderer, fetch_renderer(docubit.type.id))
  end

  defp fetch_renderer(type_id) do
    "Elixir.UserDocs.Documents.DocuBit.Renderers."
    <> String.capitalize(type_id)
    |> String.to_existing_atom()
  end

end
