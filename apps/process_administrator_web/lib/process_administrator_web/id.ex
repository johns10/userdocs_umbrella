defmodule ProcessAdministratorWeb.ID do
  require Logger

  def group(type, id) do
    type
    <> "-group-"
    <> Integer.to_string(id)
  end

  def embedded_form(parent, action, object) do
    type_from_struct(parent) <> "-"
    <> Integer.to_string(parent.id) <> "-"
    <> Atom.to_string(action) <> "-related-"
    <> type_from_struct(object)
  end

  def nested_form(parent, object) do
    prefix(parent)
    <> prefix(object)
    <> "-nested-form"
  end

  def form(parent, :new = action, type) do
    prefix(parent)
    <> Atom.to_string(action) <> "-"
    <> type_from_module(type)
  end

  def form(object, :edit = action, type) do
    type_from_module(type) <> "-"
    <> Integer.to_string(object.id) <> "-"
    <> Atom.to_string(action)
  end

  def nested_form(object, prefix) do

  end

  def form_field(data, name, %{}), do: form_field(data,name)
  def form_field(data, name, prefix), do: nested_form_field(data,name,prefix)
  def form_field(data, name) do
    # Logger.debug("Generating form field ID")
    prefix(data)
    <> Atom.to_string(name)
  end

  def nested_form_field(data, name, prefix) do
    prefix
    <> type_from_struct(data) <> "-"
    <> maybe_id(data.id) <> "-"
    <> Atom.to_string(name)
  end

  def type_from_struct(nil) do
    Logger.error("Tried to get a type from a nil object")
    "nil"
  end
  def type_from_struct(object) do
    object.__meta__.schema
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.at(-1)
    |> String.downcase()
  end

  def type_from_module(object) do
    object
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.at(-1)
    |> String.downcase()
  end

  def strategy_field(page_id, element_id) do
    page_prefix(page_id) <> "-"
    <> element_prefix(element_id)
    <> "-strategy-field"
  end

  def selector_field(page_id, element_id) do
    page_prefix(page_id) <> "-"
    <> element_prefix(element_id)
    <> "-form-selector-field"
  end

  def page_prefix(nil), do: "page-not-assigned"
  def page_prefix(page_id) do
    "page-"
    <> Integer.to_string(page_id)
  end

  def element_prefix(nil), do: "element-not-assigned"
  def element_prefix(page_id) do
    "element-"
    <> Integer.to_string(page_id)
  end

  def prefix(nil) do
    Logger.error("Tried to generate a prefix for a nil object")
    "nil"
  end
  def prefix(object) do
    type_from_struct(object) <> "-"
    <> maybe_id(object.id) <> "-"
  end

  # This function generates the portion of the ID that represents the id of the object
  # We use this because sometimes the object is new, and has a nil id.  We may have to do
  # Something for temporary id's later
  def maybe_id(nil), do: UserDocs.ID.temp_id()
  def maybe_id(id) when is_integer(id) do
    Integer.to_string(id)
  end
end
