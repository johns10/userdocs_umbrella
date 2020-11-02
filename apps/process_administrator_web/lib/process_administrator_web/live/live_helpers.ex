defmodule ProcessAdministratorWeb.LiveHelpers do
  alias UserDocsWeb

  alias ProcessAdministratorWeb.CollapsableFormComponent
  alias ProcessAdministratorWeb.GroupComponent
  alias ProcessAdministratorWeb.EmbeddedFormComponent
  alias ProcessAdministratorWeb.NestedFormComponent
  alias ProcessAdministratorWeb.VersionPicker
  alias ProcessAdministratorWeb.ModalMenus
  alias ProcessAdministratorWeb.ModalComponent

  import Phoenix.LiveView.Helpers

  require Logger

  def live_modal(socket, component, opts) do
    modal_opts = [
      id: :modal,
      component: component,
      opts: opts
    ]

    live_component(socket, ModalComponent, modal_opts)
  end

  def live_modal_menus(socket, opts) do
    picker_opts = [
      id: Keyword.fetch!(opts, :id),
      action: Keyword.fetch!(opts, :action),
    ]

    live_component(socket, ModalMenus, picker_opts)
  end

  def live_version_picker(socket, opts) do
    picker_opts = [
      id: Keyword.fetch!(opts, :id),
      current_user: Keyword.fetch!(opts, :current_user),
      current_team: Keyword.fetch!(opts, :current_team),
      current_team_id: Keyword.fetch!(opts, :current_team_id),
      current_project: Keyword.fetch!(opts, :current_project),
      current_project_id: Keyword.fetch!(opts, :current_project_id),
      current_version: Keyword.fetch!(opts, :current_version),
      current_version_id: Keyword.fetch!(opts, :current_version_id),
      data: Keyword.fetch!(opts, :data),
      live_action: Keyword.fetch!(opts, :live_action),
    ]

    live_component(socket, VersionPicker, picker_opts)
  end

  def live_nested_form(socket, opts) do
    form_opts = [
      id: Keyword.fetch!(opts, :id),
      field: Keyword.fetch!(opts, :field),
      form: Keyword.fetch!(opts, :form),
      selected: Keyword.fetch!(opts, :selected),
      select_options: Keyword.fetch!(opts, :select_options),
    ]
    live_component(socket, NestedFormComponent, form_opts)
  end

  def live_collapsible_form(socket, opts) do
    form_opts = [
      id: Keyword.fetch!(opts, :id),
      title: Keyword.fetch!(opts, :title),
      parent: Keyword.fetch!(opts, :parent),
      object: Keyword.fetch!(opts, :object),
      object_type: Keyword.fetch!(opts, :object_type),
      object_form: Keyword.fetch!(opts, :object_form),
      action: Keyword.fetch!(opts, :action),
      data: Keyword.fetch!(opts, :data),
      select_lists: Keyword.fetch!(opts, :select_lists),
      runner: Keyword.fetch!(opts, :runner),
    ]

    live_component(socket, CollapsableFormComponent, form_opts)
  end

  def live_group(socket, opts) do
    group_opts = [
      id: Keyword.fetch!(opts, :id),
      parent: Keyword.fetch!(opts, :parent),
      object: Keyword.fetch!(opts, :object),
      object_form: Keyword.fetch!(opts, :object_form),
      child_type: Keyword.fetch!(opts, :child_type),
      new_form_component: Keyword.fetch!(opts, :new_form_component),
      new_form_object: Keyword.fetch!(opts, :new_form_object),
      data: Keyword.fetch!(opts, :data),
      select_lists: Keyword.fetch!(opts, :select_lists),
      object_type: Keyword.fetch!(opts, :object_type),
      runner: Keyword.fetch!(opts, :runner),
      content: Keyword.fetch!(opts, :content),
      opts: opts
    ]

    live_component(socket, GroupComponent, group_opts)
  end

  def apply_changes(socket, changes) do
    Enum.reduce(changes, socket, fn({x, y}, acc) -> Phoenix.LiveView.assign(acc, x, y) end)
  end

  def live_form(socket, form_component, opts) do
    action = Keyword.fetch!(opts, :action)
    form_opts = form_opts(socket, action, opts)

    live_component(socket, form_component, form_opts)
  end

  def form_opts(_, :edit, opts) do
    type_key =
      Keyword.fetch!(opts, :type)
      |> type_atom_from_module()

    base_form_opts(opts)
    |> Keyword.put(type_key, Keyword.fetch!(opts, :object))
  end
  def form_opts(_, :new, opts) do
    type = Keyword.fetch!(opts, :type)
    type_key = type_atom_from_module(type)

    base_form_opts(opts)
    |> Keyword.put(type_key, struct(type))
  end

  def base_form_opts(opts) do
    [
      parent_id: parent_id(opts),
      parent: Keyword.fetch!(opts, :parent),
      id: Keyword.fetch!(opts, :id),
      action: Keyword.fetch!(opts, :action),
      data: Keyword.fetch!(opts, :data),
      select_lists: Keyword.fetch!(opts, :select_lists),
      enabled_fields: [],
      opts: opts
    ]
  end

  def level(socket, opts) do
    ProcessAdministratorWeb.LevelComponent.render(opts)
  end

  def parent_id(opts) do
    opts
    |> Keyword.fetch!(:parent)
    |> Map.get(:id)
  end

  def type_atom_from_module(module) do
    module
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.at(-1)
    |> String.downcase()
    |> String.to_atom()
  end
end
