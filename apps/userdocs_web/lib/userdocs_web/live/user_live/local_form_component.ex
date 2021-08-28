defmodule UserDocsWeb.UserLive.LocalFormComponent do
  @moduledoc """
    This is used to modify settings on the users local machine
  """
  use UserDocsWeb, :live_slime_component

  alias UserDocs.Users
  alias UserDocs.Users.LocalOptions
  alias UserDocs.Users.Override
  alias UserDocsWeb.LiveHelpers

  @impl true
  def update(%{params: params} = assigns, %{assigns: %{current_user: user}} = socket) do
    {:ok, socket |> put_configuration_response(params, user) |> assign(assigns)}
  end
  def update(%{chrome_path: chrome_path}, socket) do
    changeset = Ecto.Changeset.put_change(socket.assigns.changeset, :chrome_path, chrome_path)
    {:ok, assign(socket, :changeset, changeset)}
  end
  def update(%{current_user: user} = assigns, socket) do
    UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "command:get_configuration", %{})
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, nil)
    }
  end

  @impl true
  def handle_event("find-chrome", _attrs, %{assigns: %{current_user: user}} = socket) do
    UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "command:find_chrome", %{})
    {:noreply, socket}
  end
  def handle_event("validate", %{"local_options" => params}, socket) do
    changeset =
      socket.assigns.local_options
      |> LocalOptions.changeset(params)
      |> Map.put(:action, :validate)

    {
      :noreply,
      assign(socket, :changeset, changeset)
    }
  end
  def handle_event("save", %{"local_options" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(%{assigns: %{current_user: user}} = socket, _, local_options_params) do
    case Users.update_local_options(socket.assigns.local_options, local_options_params) do
      {:ok, local_options} ->
        overrides =
          local_options.overrides
          |> Enum.map(fn(o) -> Map.take(o, [:url, :project_id]) end)

        snake_cased_local_options =
          local_options
          |> Map.put(:overrides, overrides)
          |> Map.take(LocalOptions.__schema__(:fields))
          |> LiveHelpers.camel_cased_map_keys()

        UserDocsWeb.Endpoint.broadcast("user:" <> to_string(user.id), "command:put_configuration", snake_cased_local_options)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end


  defp put_configuration_response(socket, params, user) do
    overrides =
      user.overrides
      |> Enum.map(fn(o) -> Map.take(o, Override.__schema__(:fields)) end)

    snake_cased_params =
      LiveHelpers.underscored_map_keys(params)
      |> Map.put("css", socket.assigns.current_team.css)
      |> Map.put("overrides", overrides)

    changeset = Users.change_local_options(%LocalOptions{}, snake_cased_params)
    local_options = Ecto.Changeset.apply_changes(changeset)

    socket
    |> assign(:changeset, changeset)
    |> assign(:local_options, local_options)
  end
end
