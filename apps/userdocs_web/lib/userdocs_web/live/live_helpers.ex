defmodule UserDocsWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  require Logger

  alias Phoenix.LiveView

  def underscored_map_keys(%Date{} = val), do: val
  def underscored_map_keys(%DateTime{} = val), do: val
  def underscored_map_keys(%NaiveDateTime{} = val), do: val
  def underscored_map_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      {Inflex.underscore(key), underscored_map_keys(val)}
    end
  end
  def underscored_map_keys(val), do: val

  def camel_cased_map_keys(%Date{} = val), do: val
  def camel_cased_map_keys(%DateTime{} = val), do: val
  def camel_cased_map_keys(%NaiveDateTime{} = val), do: val
  def camel_cased_map_keys(items) when is_list(items), do: Enum.map(items, &camel_cased_map_keys/1)
  def camel_cased_map_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      {Inflex.camelize(key, :lower), camel_cased_map_keys(val)}
    end
  end
  def camel_cased_map_keys(val), do: val

  def which_app(conn) do
    %{"app_name" => Atom.to_string(conn.assigns.app_name)}
  end

  def live_modal(socket, component, opts) do
    modal_opts = [
      id: :modal,
      component: component,
      opts: opts
    ]

    socket
    |> live_component(UserDocsWeb.ModalComponent, modal_opts)
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
      opts: opts
    ]
    |> Keyword.put(type, maybe_object(action, object, struct))

    socket
    |> live_component(form, form_opts)
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
  ### MARKED FOR DELETION ###
  """
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
  """
  def maybe_action(assigns) do
    try do
      Map.get(assigns, :action)
    rescue
      _ -> :edit
    end
  end
end
