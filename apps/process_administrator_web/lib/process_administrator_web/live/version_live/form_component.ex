defmodule ProcessAdministratorWeb.VersionLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Projects
  alias ProcessAdministratorWeb.Layout

  @impl true
  def update(%{version: version} = assigns, socket) do
    changeset = Projects.change_version(version)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
    }
  end
  def update(assigns, socket) do
    raise(RuntimeError, "Version Live Failed to update because it was called without a version")
  end

  @impl true
  def handle_event("validate", %{"version" => version_params}, socket) do
    changeset =
      socket.assigns.version
      |> Projects.change_version(version_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"version" => version_params}, socket) do
    save_version(socket, socket.assigns.action, version_params)
  end

  defp save_version(socket, :edit, version_params) do
    case Projects.update_version(socket.assigns.version, version_params) do
      {:ok, _version} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Version updated successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_version(socket, :new, version_params) do
    case Projects.create_version(version_params) do
      {:ok, _version} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Version created successfully")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
