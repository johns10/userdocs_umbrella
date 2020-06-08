defmodule UserDocsWeb.TeamUserLive.FormComponent do
  use UserDocsWeb, :live_component
  alias UserDocsWeb.DomainHelpers

  alias UserDocs.Users

  @impl true
  def update(%{team_user: team_user} = assigns, socket) do
    changeset = Users.change_team_user(team_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"team_user" => team_user_params}, socket) do
    changeset =
      socket.assigns.team_user
      |> Users.change_team_user(team_user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"team_user" => team_user_params}, socket) do
    save_team_user(socket, socket.assigns.action, team_user_params)
  end

  defp save_team_user(socket, :edit, team_user_params) do
    case Users.update_team_user(socket.assigns.team_user, team_user_params) do
      {:ok, _team_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team user updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_team_user(socket, :new, team_user_params) do
    case Users.create_team_user(team_user_params) do
      {:ok, _team_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team user created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
