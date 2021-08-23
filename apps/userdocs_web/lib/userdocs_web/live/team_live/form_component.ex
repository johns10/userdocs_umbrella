defmodule UserDocsWeb.TeamLive.FormComponent do
  use UserDocsWeb, :live_component

  use UserdocsWeb.LiveViewPowHelper
  alias UserDocsWeb.Layout

  alias UserDocs.Users
  alias UserDocs.Helpers
  alias UserDocs.Users.TeamUser


  @aws_region_select_options [
    "US East (Ohio)": "us-east-2",
    "US East (N. Virginia)": "us-east-1",
    "US West (N. California)": "us-west-1",
    "US West (Oregon)": "us-west-2",
    "Africa (Cape Town)": "af-south-1",
    "Asia Pacific (Hong Kong)": "ap-east-1",
    "Asia Pacific (Mumbai)": "ap-south-1",
    "Asia Pacific (Osaka)": "ap-northeast-3",
    "Asia Pacific (Seoul)": "ap-northeast-2",
    "Asia Pacific (Singapore)": "ap-southeast-1",
    "Asia Pacific (Sydney)": "ap-southeast-2",
    "Asia Pacific (Tokyo)": "ap-northeast-1",
    "Canada (Central)": "ca-central-1",
    "China (Beijing)": "cn-north-1",
    "China (Ningxia)": "cn-northwest-1",
    "Europe (Frankfurt)": "eu-central-1",
    "Europe (Ireland)": "eu-west-1",
    "Europe (London)": "eu-west-2",
    "Europe (Milan)": "eu-south-1",
    "Europe (Paris)": "eu-west-3",
    "Europe (Stockholm)": "eu-north-1",
    "Middle East (Bahrain)": "me-south-1",
    "South America (São Paulo)": "sa-east-1",
    "AWS GovCloud (US-East)": "us-gov-east-1",
    "AWS GovCloud (US-West)": "us-gov-west-1"
  ]


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
      |> assign(:aws_region_select_options, @aws_region_select_options)
      |> assign(:changeset, changeset)
      |> assign(:users_select_options, users_select)
      |> assign(:show_user_form, false)
    }
  end

  @impl true
  def handle_event("validate", %{"team" => team_params}, socket) do
    changeset =
      socket.assigns.team
      |> Users.change_team(team_params)
      |> Users.Team.change_default_project()
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    save_team(socket, socket.assigns.action, team_params)
  end

  def handle_event("add-user", _, socket) do
    last_team_user_change = socket.assigns.changeset |> Ecto.Changeset.get_change(:team_users, []) |> Enum.at(-1)
    new_team_user =
      %TeamUser{temp_id: get_temp_id()}
      |> Users.change_team_user()
      |> Ecto.Changeset.put_change(:user, %Users.User{})

    team_user_changes =
      socket.assigns.changeset
      |> Ecto.Changeset.get_change(:team_users, socket.assigns.team.team_users)
      |> Enum.concat([new_team_user])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:team_users, team_user_changes)

      {:noreply, socket |> assign(:changeset, changeset) |> assign(:show_user_form, true)}
  end

  def handle_event("remove-user", %{"remove" => remove_id}, socket) do
    team_user_changes =
      socket.assigns.changeset
      |> Ecto.Changeset.get_change(:team_users)
      |> Enum.reject(fn(c) -> c.action == :insert end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:team_users, team_user_changes)

    {:noreply, socket |> assign(:changeset, changeset) |> assign(:show_user_form, false)}
  end

  def handle_event("send-invitation", _params, socket = %{assigns: %{changeset: %{params: %{"team_users" => team_users} = params}}}) do
    {key, team_user_attrs} = team_users |> Enum.into([]) |> Enum.at(-1)
    user_attrs = Map.get(team_user_attrs, "user")
    team_user_attrs = Map.delete(team_user_attrs, "user")

    case Users.invite_user(%Users.User{}, user_attrs) do
      {:ok, user} ->
        signed_token =
          %Plug.Conn{secret_key_base: UserDocsWeb.Endpoint.config(:secret_key_base)}
          |> Pow.Plug.put_config(otp_app: :userdocs_web)
          |> PowInvitation.Plug.sign_invitation_token(user)

        %{
          url: UserDocsWeb.Endpoint.url <> Routes.pow_invitation_invitation_path(socket, :edit, signed_token),
          user: user,
          invited_by: socket.assigns.current_user,
        }
        |>  Users.send_email_invitation()

        {:ok, _team_user} = Map.put(team_user_attrs, "user_id", user.id) |> Users.create_team_user()
        team = Users.get_team!(socket.assigns.team.id, %{preloads: [team_users: [user: true], projects: true]})
        team_user_params = team_users |> Enum.into([]) |> List.delete_at(-1)
        params = params |> Map.delete("team_users") |> Map.put("team_users", team_user_params)
        changeset = Users.change_team(team, params)

        {
          :noreply,
          socket
          |> assign(:team, team)
          |> assign(:changeset, changeset)
          |> assign(:append_team_users, [])
          |> assign(:show_user_form, false)
        }
      {:error, %{changes: %{email: email}, errors: [email: {"has already been taken", _}]}} ->
        IO.puts("Email taken")
        user = Users.get_user_by_email!(email)

        {:ok, _team_user} =
          team_user_attrs
          |> Map.put("user_id", user.id)
          |> Users.create_team_user()

        team = Users.get_team!(socket.assigns.team.id, %{preloads: [team_users: [user: true], projects: true]})
        team_user_params = team_users |> Enum.into([]) |> List.delete_at(-1)
        params = params |> Map.delete("team_users") |> Map.put("team_users", team_user_params)
        changeset = Users.change_team(team, params)

        {
          :noreply,
          socket
          |> assign(:team, team)
          |> assign(:changeset, changeset)
          |> assign(:append_team_users, [])
          |> assign(:show_user_form, false)
        }
      {:error, changeset} ->
        {:noreply, socket}
    end
  end

  defp get_temp_id, do: :crypto.strong_rand_bytes(5) |> Base.url_encode64 |> binary_part(0, 5)

  defp save_team(socket, :edit, team_params) do
    case Users.update_team(socket.assigns.team, team_params) do
      {:ok, _team} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Team updated successfully")
          |> push_redirect(to: socket.assigns.return_to)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_team(socket, :new, team_params) do
    params = Map.put(team_params, "team_users", [%{"default" => "false", "user_id" => Integer.to_string(socket.assigns.current_user.id)}])
    case Users.create_team(params) do
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
