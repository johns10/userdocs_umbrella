defmodule UserDocs.Documents.Docubit.Renderers.Container do
  require Logger
  use Phoenix.HTML

  def render(assigns, :editor) do
    content_tag(:div, [ class: "container is-widescreen" ]) do
      "Container"
      link(to: "#", class: "button",
        phx_click: "create-docubit",
        phx_value_id: assigns.id,
        phx_value_docubit_type: "row"
      ) do
        "+"
      end
    end
  end
end
