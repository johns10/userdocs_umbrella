defmodule UserDocsWeb.Layout do
  use UserDocsWeb, :view
  alias Phoenix.HTML.Form
  alias UserDocsWeb.ErrorHelpers

  alias UserDocsWeb.Layout

  def checkbox(form,
    name \\ :default,
    _select_options \\ [{None, ""}],
    placeholder \\ None,
    id \\ "checkbox-input",
    readonly \\ false,
    visible \\ true
  ) do
    class =
      if visible do
        "field"
      else
        "field is-hidden"
      end

    content_tag(:div, [class: class]) do
      [
        label(form, name, [class: "label"]),
        content_tag(:div, [class: "control"]) do
          content_tag(:div, [class: "checkbox"]) do
            Form.checkbox(form, name, [
              type: "checkbox",
              placeholder: placeholder,
              id: id,
              readonly: readonly
            ])
          end
        end,
        ErrorHelpers.error_tag(form, name)
      ]
    end
  end

  def edit_item_button(event, opts, wrapper_class) do
    wrapper(opts, wrapper_class, edit_item_button(event, opts))
  end
  def edit_item_button(event, opts) do
    item_button(event, opts ++ [{:icon_class, "fa fa-edit"}])
  end

  def new_item_button(event, opts, wrapper_class) do
    wrapper(opts, wrapper_class, new_item_button(event, opts))
  end
  def new_item_button(event, opts) do
    item_button(event, opts ++ [{:icon_class, "fa fa-plus"}])
  end

  def item_button(event, opts) do
    icon_opts = [class: opts[:icon_class], aria_hidden: true]
    button_opts =
      [class: :button, phx_click: event]
      |> maybe_opt(opts, :target)
      |> maybe_opt(opts, :phx_target)
      |> maybe_opt(opts, :button_class, :button)

    content_tag(button_opts[:button_class], button_opts) do
      content_tag(:span, [class: :i]) do
        content_tag(:i, "", icon_opts)
      end
    end
  end

  def select_input(form, name, select_options, opts, wrapper_class) do
    wrapper(opts, wrapper_class, Layout.select_input(form, name, select_options, opts))
  end
  def select_input(form, name, select_options, opts) do
    input_opts = input_opts(opts)
    layout =
      []
      |> maybe_opt(opts, :label, true)

    content_tag(:div, [class: maybe_hidden(input_opts, "field")]) do
      [
        if layout[:label] do
          label(form, name, [class: :label])
        else
          ""
        end,
        content_tag(:div, [class: :control]) do
          content_tag(:div, [class: :select]) do
            Form.select(form, name, select_options, input_opts)
          end
        end,
        ErrorHelpers.error_tag(form, name)
      ]
    end
  end

  def text_input(form, name, opts, wrapper_class) when is_atom(name) and is_list(opts) and is_bitstring(wrapper_class) do
    wrapper(opts, wrapper_class, Layout.text_input(form, name, opts))
  end
  def text_input(form, opts, wrapper_class) when is_list(opts) and is_bitstring(wrapper_class) do
    wrapper(opts, wrapper_class, Layout.text_input(form, opts))
  end
  def text_input(form, name, opts) when is_atom(name) and is_list(opts) do
    # Required Options
    input_opts = input_opts(opts)
    layout =
      []
      |> maybe_opt(opts, :label, true)

    content_tag(:div, [class: maybe_hidden(input_opts, "field")]) do
      [
        if layout[:label] do
          label(form, name, [class: :label])
        else
          ""
        end,
        content_tag(:div, [class: :control]) do
          Form.text_input(form, name, input_opts)
        end,
        ErrorHelpers.error_tag(form, name)
      ]
    end
  end
  def text_input(form, opts) when is_list(opts) do
    # Required Options
    field_name = opts[:field_name]
    Layout.text_input(form, field_name, opts)
  end

  def maybe_opt(opts, source, key, default) do
    try do
      opts ++ [{key, Keyword.fetch!(source, key)}]
    rescue
      _ -> opts ++ [{key, default}]
    end
  end
  def maybe_opt(opts, source, key) do
    try do
      opts ++ [{key, Keyword.fetch!(source, key)}]
    rescue
      _ -> opts
    end
  end

  def maybe_hidden(opts, class) do
    if opts[:hidden] do
      class <>" is-hidden"
    else
      class
    end
  end

  def number_input(form, name, opts, wrapper_class) when is_atom(name) and is_list(opts) and is_bitstring(wrapper_class) do
    wrapper(opts, wrapper_class, Layout.number_input(form, name, opts))
  end
  def number_input(form, opts, wrapper_class) when is_list(opts) and is_bitstring(wrapper_class) do
    wrapper(opts, wrapper_class, Layout.number_input(form, opts))
  end
  def number_input(form, name, opts) when is_atom(name) and is_list(opts) do
    # Required Options
    input_opts = input_opts(opts)

    content_tag(:div, [class: maybe_hidden(input_opts, "field")]) do
      [
        label(form, name, [class: :label]),
        content_tag(:div, [class: "control"]) do
          Form.number_input(form, name, input_opts)
        end,
        ErrorHelpers.error_tag(form, name)
      ]
    end
  end
  def number_input(form, opts) when is_list(opts) do
    # Required Options
    field_name = opts[:field_name]
    Layout.number_input(form, field_name, opts)
  end

  def form_row(content) do
    content_tag(:div, [class: "field is-horizontal"]) do
      content_tag(:div, [class: "field-body"]) do
        content
      end
    end
  end

  defp wrapper(opts, class, content) do
    wrapper_opts =
      []
      |> maybe_opt(opts, :hidden)

    content_tag(:div, [class: maybe_hidden(wrapper_opts, class)]) do
      content
    end
  end

  defp input_opts(opts) do
    []
    |> Keyword.put(:class, "input")
    |> maybe_opt(opts, :id)
    |> maybe_opt(opts, :value)
    |> maybe_opt(opts, :hidden)
    |> maybe_opt(opts, :disabled)
    |> maybe_opt(opts, :placeholder)
    |> maybe_opt(opts, :selected)
    |> maybe_opt(opts, :phx_debounce)
  end

  # SOMe old shit I brought in

  def is_hidden?(class, true), do: class <> " is-hidden"
  def is_hidden?(class, false), do: class
  def is_hidden?(%{expanded: false}), do: " is-hidden"
  def is_hidden?(%{expanded: true}), do: ""
  def is_hidden?(%{action: :new}), do: ""
  def is_hidden?(%{action: :show}), do: " is-hidden"
  def is_hidden?(false, :new), do: ""
  def is_hidden?(_, _), do: " is-hidden"


  def form_field_id(action, f, field, parent_type, parent_id) do
    parent_id = Integer.to_string(parent_id || 0)
    field = Atom.to_string(field)

    parent_type <> "_"
    <> parent_id <> "_"
    <> field_name(f)
    <> id_or_new(action, f) <> "_"
    <> field
  end

  defp field_name(f) do
    f.data.__meta__.schema
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> Enum.at(0)
    |> String.downcase(:default)
  end

  defp id_or_new(:edit, f), do: "_" <> Integer.to_string(f.data.id)
  defp id_or_new(:new, _f), do: "_new"

  def is_expanded?(false), do: " is-hidden"
  def is_expanded?(true), do: ""
end
