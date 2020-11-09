defmodule UserDocs.Documents.OldDocuBit.Renderers.Row do
  require Logger
  use Phoenix.HTML

  def render(assigns, :editor) do
    content_tag(:div, [
      class: "columns",
      address: assigns.docubit.address
    ]) do
      assigns.docubit.content
    end
  end
end
