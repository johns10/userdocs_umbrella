defmodule UserDocs.Documents.Docubit.Renderers.DocubitEditor do
  require Logger
  use Phoenix.HTML

  def container(assigns, do: content) do
    content_tag(:div, [ class: "px-1 py-0 has-background-light" ]) do
      [
        content_tag(:nav, [
          class: "navbar",
          height: "1px",
          role: "navigation",
          aria_label: "dropdown navigation"
        ]) do
          [

            content_tag(:div, [ class: "py-1 navbar-item" ]) do
              assigns.type_id
            end,
            content_tag(:div, [class: "navbar-end"]) do
              content_tag(:div, [class: "navbar-item has-dropdown"]) do
                content_tag(:a, [class: "navbar-link py-0"]) do
                  content_tag(:i, "", [class: "fa fa-gear"])
                end
              end
            end
          ]
        end,
        content
      ]
    end
  end
end
