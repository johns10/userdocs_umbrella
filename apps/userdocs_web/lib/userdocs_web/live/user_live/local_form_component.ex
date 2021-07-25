defmodule UserDocsWeb.UserLive.LocalFormComponent do
  @moduledoc """
    This is used to modify settings on the users local machine
  """
  use UserDocsWeb, :live_slime_component

  alias UserDocs.Users
  alias UserDocs.Users.LocalOptions
  alias UserDocsWeb.LiveHelpers

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, nil)
      |> push_event("get-configuration", %{})
    }
  end

  @impl true
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

  def handle_event("configuration-response", %{"configuration" => configuration_params}, socket) do
    snake_cased_params = LiveHelpers.underscored_map_keys(configuration_params)
    changeset = Users.change_local_options(%LocalOptions{}, snake_cased_params)
    local_options = Ecto.Changeset.apply_changes(changeset)
    {
      :noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:local_options, local_options)
    }
  end

  def handle_event("configuration-saved", _payload, socket) do
    {
      :noreply,
      socket
      |> put_flash(:info, "Local Options updated successfully")
      |> push_redirect(to: socket.assigns.return_to)
    }
  end

  defp save_user(socket, _, local_options_params) do
    case Users.update_local_options(socket.assigns.local_options, local_options_params) do
      {:ok, local_options} ->
        snake_cased_local_options =
          local_options
          |> Map.take(LocalOptions.__schema__(:fields))
          |> LiveHelpers.camel_cased_map_keys()

        {
          :noreply,
          socket
          |> push_event("put-configuration", snake_cased_local_options)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
