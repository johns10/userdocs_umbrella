defmodule UserDocsWeb.VersionLive.FormComponent do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DomainHelpers
  alias UserDocs.Projects
  
  @impl true
  def update(%{version: version} = assigns, socket) do
    changeset = Projects.change_version(version)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
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
        {:noreply,
         socket
         |> put_flash(:info, "Version updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_version(socket, :new, version_params) do
    case Projects.create_version(version_params) do
      {:ok, _version} ->
        {:noreply,
         socket
         |> put_flash(:info, "Version created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
