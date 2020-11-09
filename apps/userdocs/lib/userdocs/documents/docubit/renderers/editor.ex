defmodule UserDocs.Documents.OldDocuBit.Renderers.Editor do

  require Logger

  use Phoenix.HTML

  alias UserDocs.Documents.OldDocuBit

  def annotation(docubit = %OldDocuBit{ data: %{ id: id,
    error_code: error_code, error_message: error_message}}, _content
  ) do
    [
      content_tag(:p, [ "Annotation #{id}\n" ]),
      content_tag(:p, [ error_code, ": ", error_message ]),
      delete(docubit.body_element_id)
    ]
  end
  def annotation(%OldDocuBit{ data: %{type: "nil"}}, _content) do
    content_tag(:div, [  ]) do
      [ "Rendering failed" ]
    end
  end
  def annotation(docubit = %OldDocuBit{ data: %{ type: "Badge" }}, _content) do
    Logger.debug("Rendering #{docubit.data.type} Annotation #{docubit.data.id}")

    content_tag(:div, [  ]) do
      [
        docubit.data.label,
        ". ", docubit.data.body,
        delete(docubit.body_element_id)
      ]
    end
  end
  def annotation(docubit = %OldDocuBit{ data: %{ type: "Outline" }}, _content) do
    Logger.debug("Rendering #{docubit.data.type} Annotation #{docubit.data.id}")

    content_tag(:div, [  ]) do
      [ docubit.data.body ]
    end
  end

  def step(docubit = %OldDocuBit{ data: %{ id: id, type: "image" }}, _content) do
    Logger.debug("Rendering Image Step")
    [
      content_tag(:p, [ "image #{id}\n" ]),
      delete(docubit.body_element_id),
      img_tag(docubit.data.image_url)
    ]
  end
  def step(docubit, content) do
    Logger.debug("Rendering Step")

    content_tag(:div, [  ]) do
      [ "step: ", docubit.data.image_url ]
    end
  end

  def content(docubit, _) do
    [
      content_tag(:h1) do
        [ docubit.data.title, delete(docubit.body_element_id)]
      end,
      content_tag(:p) do
        docubit.data.body
      end
    ]
  end

  def container(_, content) do
    content_tag(:div, [ class: "container" ]) do
      [
        content
      ]
    end
  end

  def row(docubit, content) do
    content_tag(:div, [
      class: "columns",
      row_count: docubit.data["row_count"]
    ]) do
      content
    end
  end

  def div(docubit, content) do
    content_tag(:div, [
      class: "column has-background-primary",
      column_count: docubit.data["column_count"],
      row_count: docubit.data["row_count"],
      phx_hook: "docubit"
    ]) do
      [ "Div Header", content ]
    end
  end

  def column(docubit, content) do
    content_tag(:div, [
      class: "box",
      column_count: docubit.data["column_count"],
      row_count: docubit.data["row_count"],
      element_id: docubit.body_element_id,
      phx_hook: "docubit"
    ]) do
      [
        content_tag(:div, [class: "content"]) do
          content
        end,
        content_tag(:nav, [class: "level is-mobile"]) do
          content_tag(:div, [class: "level-left"]) do
            delete(docubit.body_element_id)
          end
        end
      ]
    end
  end

  def add_column(docubit, _) do
    content_tag(:div, [ class: "column is-1 has-text-centered" ]) do
      content_tag(:a, [
        phx_click: "add_column",
        phx_value_column_count: docubit.data["column_count"],
        phx_value_row_count: docubit.data["row_count"]
      ]) do
        content_tag(:span, [ class: "icon" ]) do
          content_tag(:i, "", [ class: "fa fa-plus-circle fa-2x", aria_hidden: "true"])
        end
      end
    end
  end

  def add_row(docubit, _) do
    content_tag(:div, [
      class: "columns",
      row_count: docubit.data["row_count"]
    ]) do
      content_tag(:div, [ class: "column" ]) do
        content_tag(:a, [
          phx_click: "add_row",
          phx_value_column_count: docubit.data["column_count"],
          phx_value_row_count: docubit.data["row_count"]
        ]) do
          content_tag(:span, [ class: "icon" ]) do
            content_tag(:i, "", [ class: "fa fa-plus-circle fa-2x", aria_hidden: "true"])
          end
        end
      end
    end
  end

  def delete(element_id) do
    content_tag(:a, [
      phx_click: "delete_body_item",
      phx_value_body_element_id: element_id
    ]) do
      content_tag(:span, [ class: "icon" ]) do
        content_tag(:i, "", [ class: "fa fa-trash", aria_hidden: "true"])
      end
    end
  end
end
