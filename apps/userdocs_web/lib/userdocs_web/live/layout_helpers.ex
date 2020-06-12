defmodule UserDocsWeb.Layout do
  use Phoenix.HTML

  @doc """
  
  """
  def content_group(group_label, contents) do
    [
      content_tag(:h3, []) do 
        group_label 
      end,
      content_tag(:dl, []) do
        contents
      end
    ]
  end

  def content_item(contents) do
    content_tag(:dt, []) do
      contents
    end
  end

  def picker(contents, options) do
    content_tag(:div, [class: "dropdown is-active"]) do
      [
        content_tag(:div, [class: "dropdown-trigger"]) do
          content_tag(:button, [
            class: "button",
            aria_haspopup: "true",
            aria_controls: "dropdown-menu"
          ]) do
            [
              content_tag(:span, []) do 
                "Dropdown Button"
              end,
              content_tag(:span, [class: "icon is-small"]) do
                content_tag(:i, [
                  class: "fa fa-angle-down", 
                  aria_hiddn: "true"
                ]) do
                  ""
                end
              end
            ]
          end
        end,
        content_tag(:div, [
          class: "dropdown-menu",
          id: "dropdown-menu",
          role: "menu"
        ]) do
          content_tag(:div, [class: "dropdown-content"]) do
            for ({value, id} <- options) do
              [
                content_tag(:a, [
                  class: "dropdown-item",
                  value: id,
                  phx_click: "test",
                  href: "#",
                  phx_value_id: id
                ]) do
                  value
                end
              ]
            end
          end
        end
      ]
    end
  end
end
  