defmodule UserDocsWeb.ProjectLive.FormComponent do
  use UserDocsWeb, :live_component

  alias UserDocs.Projects
  alias UserDocsWeb.Layout
  alias UserDocsWeb.ID

  @impl true
  def update(%{project: project} = assigns, socket) do
    changeset = Projects.change_project(project)

    field_ids =
      %{}
      |> Map.put(:team_id, ID.form_field(project, :team_id))
      |> Map.put(:name, ID.form_field(project, :name))
      |> Map.put(:base_url, ID.form_field(project, :base_url))

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:field_ids, field_ids)
    }
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Projects.change_project(project_params)
      |> Map.put(:action, :validate)

    {
      :noreply,
      assign(socket, :changeset, changeset)
    }
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.action, project_params)
  end

  defp save_project(socket, :edit, project_params) do
    case Projects.update_project(socket.assigns.project, project_params) do
      {:ok, _project} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Project updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_project(socket, :new, project_params) do
    case Projects.create_project(project_params) do
      {:ok, _project} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Project created successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
