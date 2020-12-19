defmodule UserDocs.Documents.Docubit.Renderers.DocubitEditor do
  require Logger
  use Phoenix.HTML

  def render(assigns, do: content) do
    content_tag(:div, [
      class: "px-1 py-0 has-background-light",
      id: "docubit-" <> String.to_integer(assigns.docubit.id)
    ]) do
      [
        content_tag(:div, [
          class: "is-flex is-flex-direction-row is-justify-content-space-between py-1" ]) do
          [

            content_tag(:div, [ class: "" ]) do
              assigns.type_id
            end,
            content_tag(:a, [class: "py-0"]) do
              content_tag(:i, "", [class: "fa fa-gear"])
            end
          ]
        end,
        content
      ]
    end
  end
end
