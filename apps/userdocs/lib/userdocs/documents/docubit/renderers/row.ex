defmodule UserDocs.Documents.Docubit.Renderers.Row do
  require Logger
  use Phoenix.HTML
  alias UserDocs.Documents.Docubit.Renderers.DocubitEditor

  def render(assigns, content, :editor) do
    content_tag(:div, [
      class: "column",
      address: inspect(assigns.address)
    ]) do
      DocubitEditor.container(assigns) do
        content_tag(:div, [ class: "columns is-gapless" ]) do
          [
            content,
            content_tag(:div, class: "column is-narrow") do
              link(to: "#", class: "button",
                phx_click: "create-docubit",
                phx_value_id: assigns.id,
                phx_value_docubit_type: "column"
              ) do
                "+"
              end
            end
          ]
        end
      end
    end
  end
end
