defmodule UserDocsWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  require Logger

  alias Phoenix.LiveView
  alias UserDocsWeb.ModalMenus

  @doc """
  Renders a component inside the `UserDocsWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, UserDocsWeb.TeamUserLive.FormComponent,
        id: @team_user.id || :new,
        action: @live_action,
        team_user: @team_user,
        return_to: Routes.team_user_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    modal_opts = [
      id: :modal,
      component: component,
      opts: opts
    ]

    live_component(socket, UserDocsWeb.ModalComponent, modal_opts)
  end

  def live_modal_menus(socket, opts) do
    picker_opts = [
      id: Keyword.fetch!(opts, :id),
      form_data: Keyword.fetch!(opts, :form_data),
    ]

    live_component(socket, ModalMenus, picker_opts)
  end

  @spec live_footer(Phoenix.LiveView.Socket.t(), any, any) :: Phoenix.LiveView.Component.t()
  def live_footer(socket, component, opts) do
    type = Keyword.fetch!(opts, :type)
    id = Keyword.fetch!(opts, :id)
    title = Keyword.fetch!(opts, :title)
    hidden = Keyword.fetch!(opts, :hidden)
    action = Keyword.fetch!(opts, :action)
    select_lists = Keyword.fetch!(opts, :select_lists)

    current_user = try do
      Keyword.fetch!(opts, :current_user)
    rescue
      _ -> None
    end

    current_team = try do
      Keyword.fetch!(opts, :current_team)
    rescue
      _ -> None
    end

    current_version = try do
      Keyword.fetch!(opts, :current_version)
    rescue
      _ -> None
    end

    _log_string =
      "Creating live footer of type " <> Atom.to_string(type) <> "\n"
      <> "  title: " <> title <> "\n"
      <> "  form component: " <> Atom.to_string(component) <> "\n"
      <> "  action: " <> Atom.to_string(action) <> "\n"

    #Logger.debug(log_string)

    footer_opts = [
      id: id,
      title: title,
      hidden: hidden,
      component: component,
      select_lists: select_lists,
      current_user: current_user,
      current_team: current_team,
      current_version: current_version,
      opts: opts
    ]
    live_component(socket, UserDocsWeb.FooterComponent, footer_opts)
  end

  def live_group(socket, header, show_component, form_component, opts) do
    type = Keyword.fetch!(opts, :type)
    id = Keyword.fetch!(opts, :id)
    parent_type = Keyword.fetch!(opts, :parent_type)
    struct = Keyword.fetch!(opts, :struct)
    objects = Keyword.fetch!(opts, :objects)
    title = Keyword.fetch!(opts, :title)
    parent = Keyword.fetch!(opts, :parent)
    select_lists = Keyword.fetch!(opts, :select_lists)

    current_user = try do
      Keyword.fetch!(opts, :current_user)
    rescue
      _ -> None
    end

    current_team = try do
      Keyword.fetch!(opts, :current_team)
    rescue
      _ -> None
    end

    current_version = try do
      Keyword.fetch!(opts, :current_version)
    rescue
      _ -> None
    end

    _log_string =
      "Creating live group of type " <> Atom.to_string(type) <> "\n"
      <> "  parent_type: " <> Atom.to_string(parent_type) <> "\n"
      <> "  parent_name: " <> parent.name <> "\n"
      <> "  number of objects: " <> Integer.to_string(Enum.count(objects)) <> "\n"
      <> "  title: " <> title <> "\n"
      <> "  show component: " <> Atom.to_string(show_component) <> "\n"
      <> "  form component: " <> Atom.to_string(form_component) <> "\n"

    #Logger.debug(log_string)

    group_opts = [
      id: id,
      type: type,
      parent_type: parent_type,
      struct: struct,
      objects: objects,
      title: title,
      parent: parent,
      show: show_component,
      form: form_component,
      header: header,
      select_lists: select_lists,
      current_user: current_user,
      current_team: current_team,
      current_version: current_version,
      opts: opts
    ]
    live_component(socket, UserDocsWeb.GroupComponent, group_opts)
  end

  def live_form(socket, form, opts) do
    type = Keyword.fetch!(opts, :type)
    title = Keyword.fetch!(opts, :title)
    action = Keyword.fetch!(opts, :action)
    struct = Keyword.fetch!(opts, :struct)
    select_lists = Keyword.fetch!(opts, :select_lists)
    object = Keyword.fetch!(opts, :object)
    parent = Keyword.fetch!(opts, :parent)
    id = Keyword.fetch!(opts, :id)

    current_user = try do
      Keyword.fetch!(opts, :current_user)
    rescue
      _ -> None
    end

    current_team = try do
      Keyword.fetch!(opts, :current_team)
    rescue
      _ -> None
    end

    current_version = try do
      Keyword.fetch!(opts, :current_version)
    rescue
      _ -> None
    end

    _log_string =
      "Creating live form of type " <> Atom.to_string(type) <> "\n"
      <> "  title: " <> title <> "\n"
      <> "  form component: " <> Atom.to_string(form) <> "\n"
      <> "  action: " <> Atom.to_string(action) <> "\n"
      <> "  parent id: " <> Integer.to_string(parent.id) <> "\n"

    # Logger.debug(log_string)

    form_opts = [
      id: id,
      title: title,
      action: action,
      select_lists: select_lists,
      parent: parent,
      struct: struct,
      current_user: current_user,
      current_team: current_team,
      current_version: current_version,
      opts: opts
    ]
    |> Keyword.put(type, maybe_object(action, object, struct))

    live_component(socket, form, form_opts)
  end

  def live_embedded_form(socket, form, opts) do
    type = Keyword.fetch!(opts, :type)
    title = Keyword.fetch!(opts, :title)
    action = Keyword.fetch!(opts, :action)
    id = Keyword.fetch!(opts, :id)
    object = Keyword.fetch!(opts, :object)
    struct = Keyword.fetch!(opts, :struct)
    parent = Keyword.fetch!(opts, :parent)
    select_lists = Keyword.fetch!(opts, :select_lists)

    log_string =
      "Creating embedded form"
    Logger.debug(log_string)

    form_opts = [
      type: type,
      title: title,
      action: action,
      id: id,
      parent: parent,
      select_lists: select_lists
    ]
    |> Keyword.put(type, maybe_object(action, object, struct))

    live_component(socket, form, form_opts)
  end

  def maybe_assign_opt(socket, target_key, source_key) do
    try do
      Phoenix.LiveView.assign(socket, target_key, Keyword.fetch!(socket.assigns.opts, source_key))
    rescue
      AttributeError -> socket
    end
  end

  def maybe_add_to_component(component_opts, opts, key) do
    IO.puts("Attempting to add #{key} to component opts")
    try do
      value = Keyword.fetch!(opts, key)
      component_opts ++ [{key, value}]
    rescue
      AttributeError -> component_opts
    end
  end

  def maybe_push_redirect(socket = %{assigns: %{return_to: return_to}}) do
    LiveView.push_redirect(socket, to: return_to)
  end
  def maybe_push_redirect(socket), do: socket

  def read_only?(assigns) do
    action =
      try do
        Map.get(assigns, :action)
      rescue
        _ -> :false
      end

    if(action in [:new, :edit]) do
      false
    else
      true
    end
  end

  def maybe_value("Elixir.None", other_value), do: other_value
  def maybe_value(None, other_value), do: other_value
  def maybe_value(nil, other_value), do: other_value
  def maybe_value(value, _) when is_integer(value), do: Integer.to_string(value)
  def maybe_value(value, _), do: value

  def maybe_object(:new, _, struct), do: struct
  def maybe_object(:edit, object, _), do: object
  def maybe_object(:show, object, _), do: object

  def enabled_fields(_, "Elixir.None"), do: []
  def enabled_fields(_, ""), do: []
  def enabled_fields(_, nil), do: []
  def enabled_fields(objects, id) when is_bitstring(id) do
    enabled_fields(objects, String.to_integer(id))
  end
  def enabled_fields(objects, id) when is_integer(id) do
    Enum.filter(objects, fn(x) -> x.id == id end)
    |> Enum.at(0)
    |> Map.get(:args)
  end

  ### MARKED FOR DELETION ###
  def maybe_action(assigns) do
    try do
      Map.get(assigns, :action)
    rescue
      _ -> :edit
    end
  end
end
