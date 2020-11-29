defmodule UserDocs.Documents.Docubit.Renderers.Column do
  require Logger
  use Phoenix.HTML

  def render(assigns, content, :editor) do
    content_tag(:div, [
      class: "column",
      address: assigns.address
    ]) do
      [ "column", content ]
    end
  end
end
