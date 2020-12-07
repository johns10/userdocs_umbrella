defmodule UserDocs.Documents.Docubit.Renderers.P do
  require Logger
  use Phoenix.HTML
  alias UserDocs.Documents.Docubit.Renderers.DocubitEditor

  def render(assigns, content, :editor) do
    DocubitEditor.container(assigns) do
      content_tag(:p, [
        class: "",
        address: assigns.address
      ]) do
        content
      end
    end
  end
end
