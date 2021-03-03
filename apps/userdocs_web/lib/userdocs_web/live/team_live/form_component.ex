defmodule UserDocsWeb.TeamLive.FormComponent do
  use UserDocsWeb, :live_component

  use UserdocsWeb.LiveViewPowHelper
  alias UserDocsWeb.Layout

  alias UserDocs.Users
  alias UserDocs.Helpers
  alias UserDocs.Users.TeamUser


  @impl true
  def update(%{team: team} = assigns, socket) do
    changeset = Users.change_team(team)
    users_select =
      Users.list_users(assigns, assigns.state_opts)
      |> Helpers.select_list(:email, false)

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:changeset, changeset)
      |> assign(:users_select_options, users_select)
    }
  end

  @impl true
  def handle_event("validate", %{"team" => team_params}, socket) do
    changeset =
      socket.assigns.team
      |> Users.change_team(team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    save_team(socket, socket.assigns.action, team_params)
  end

  def handle_event("add-user", _, socket) do
    existing_team_users =
      Map.get(
        socket.assigns.changeset.changes, :team_users,
        socket.assigns.team.team_users
      )

    team_users =
      existing_team_users
      |> Enum.concat([
        Users.change_team_user(%TeamUser{temp_id: get_temp_id()})
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:team_users, team_users)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-user", %{"remove" => remove_id}, socket) do
    team_users =
      socket.assigns.changeset.changes.team_users
      |> Enum.reject(fn %{data: team_user} ->
        team_user.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:team_users, team_users)

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)

  defp save_team(socket, :edit, team_params) do
    case Users.update_team(socket.assigns.team, team_params) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_team(socket, :new, team_params) do
    case Users.create_team(team_params) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
