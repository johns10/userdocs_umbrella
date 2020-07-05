defmodule UserDocsWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  require Logger

  alias Phoenix.LiveView

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
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [
      id: :modal,
      return_to: path,
      component: component,
      opts: opts
    ]
    live_component(socket, UserDocsWeb.ModalComponent, modal_opts)
  end

  @spec live_footer(Phoenix.LiveView.Socket.t(), any, any) :: Phoenix.LiveView.Component.t()
  def live_footer(socket, component, opts) do
    type = Keyword.fetch!(opts, :type)
    id = Keyword.fetch!(opts, :id)
    title = Keyword.fetch!(opts, :title)
    hidden = Keyword.fetch!(opts, :hidden)
    action = Keyword.fetch!(opts, :action)
    select_lists = Keyword.fetch!(opts, :select_lists)

    log_string =
      "Creating live footer of type " <> Atom.to_string(type) <> "\n"
      <> "  title: " <> title <> "\n"
      <> "  form component: " <> Atom.to_string(component) <> "\n"
      <> "  action: " <> Atom.to_string(action) <> "\n"

    Logger.debug(log_string)

    footer_opts = [
      id: id,
      title: title,
      hidden: hidden,
      component: component,
      select_lists: select_lists,
      opts: opts
    ]
    live_component(socket, UserDocsWeb.FooterComponent, footer_opts)
  end

  def live_group(socket, show_component, form_component, opts) do
    type = Keyword.fetch!(opts, :type)
    id = Keyword.fetch!(opts, :id)
    parent_type = Keyword.fetch!(opts, :parent_type)
    struct = Keyword.fetch!(opts, :struct)
    objects = Keyword.fetch!(opts, :objects)
    title = Keyword.fetch!(opts, :title)
    parent = Keyword.fetch!(opts, :parent)
    select_lists = Keyword.fetch!(opts, :select_lists)

    log_string =
      "Creating live group of type " <> Atom.to_string(type) <> "\n"
      <> "  parent_type: " <> Atom.to_string(parent_type) <> "\n"
      <> "  parent_name: " <> parent.name <> "\n"
      <> "  number of objects: " <> Integer.to_string(Enum.count(objects)) <> "\n"
      <> "  title: " <> title <> "\n"
      <> "  show component: " <> Atom.to_string(show_component) <> "\n"
      <> "  form component: " <> Atom.to_string(form_component) <> "\n"

    Logger.debug(log_string)

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
      select_lists: select_lists,
      opts: opts
    ]
    live_component(socket, UserDocsWeb.GroupComponent, group_opts)
  end

  def live_show(socket, show, form, opts) do
    type = Keyword.fetch!(opts, :type)
    object = Keyword.fetch!(opts, :object)
    select_lists = Keyword.fetch!(opts, :select_lists)

    show_opts = [
      id: Keyword.fetch!(opts, :id),
      name: object.name,
      show: show,
      form: form,
      select_lists: select_lists,
      opts: [ {type, object} | opts ]
    ]
    |> Keyword.put(type, object)

    live_component(socket, UserDocsWeb.ShowComponent, show_opts)
  end

  def live_form(socket, form, opts) do
    type = Keyword.fetch!(opts, :type)
    title = Keyword.fetch!(opts, :title)
    action = Keyword.fetch!(opts, :action)
    struct = Keyword.fetch!(opts, :struct)
    select_lists = Keyword.fetch!(opts, :select_lists)

    log_string =
      "Creating live form of type " <> Atom.to_string(type) <> "\n"
      <> "  title: " <> title <> "\n"
      <> "  form component: " <> Atom.to_string(form) <> "\n"
      <> "  action: " <> Atom.to_string(action) <> "\n"

    Logger.debug(log_string)

    form_opts = [
      id: Keyword.fetch!(opts, :id),
      title: title,
      action: action,
      select_lists: select_lists,
      opts: opts
    ]
    |> Keyword.put(type, struct)

    live_component(socket, form, form_opts)
  end

  def maybe_push_redirect(socket = %{assigns: %{return_to: return_to}}) do
    LiveView.push_redirect(socket, to: return_to)
  end
  def maybe_push_redirect(socket), do: socket

  def maybe_action(assigns) do
    try do
      Map.get(assigns, :action)
    rescue
      _ -> :edit
    end
  end
end
