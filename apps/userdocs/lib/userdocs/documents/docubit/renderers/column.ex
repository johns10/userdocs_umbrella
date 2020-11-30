defmodule UserDocs.Documents.Docubit.Renderers.Column do
  require Logger
  use Phoenix.HTML
  alias UserDocs.Documents.Docubit.Renderers.DocubitEditor

  def render(assigns, content, :editor) do
    content_tag(:div, [
      class: "column",
      address: assigns.address
    ]) do
      DocubitEditor.container(assigns) do
        [
          content,
          link(to: "#",
            class: "button is-fullwidth py-0 px-0",
            phx_click: "create-docubit",
            phx_value_id: assigns.id,
            phx_value_docubit_type: ""
          ) do
            "+"
          end
        ]
      end
    end
  end
end
