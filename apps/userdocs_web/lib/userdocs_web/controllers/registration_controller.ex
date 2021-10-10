defmodule UserDocsWeb.RegistrationController do
  use UserDocsWeb, :controller
  alias UserDocs.Users
  alias UserDocs.Web

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        {:ok, team} = Users.create_team(%{name: team_name(user.email)})
        {:ok, _team_user} = Users.create_team_user(%{user_id: user.id, team_id: team.id})
        {:ok, project} = UserDocs.Projects.create_project(%{
          team_id: team.id,
          default: true,
          name: "Default",
          base_url: "https://www.example.com",
          strategy_id: Web.css_strategy() |> Map.get(:id)
        })
        {:ok, user} = Users.update_user_options(user, %{selected_team_id: team.id, selected_project_id: project.id})
        PowEmailConfirmation.Phoenix.ControllerCallbacks.send_confirmation_email(user, conn)
        redirect(conn, to: Routes.registration_path(conn, :edit, user))
      {:error, _changeset} -> conn
    end
  end

  def team_name(email) do
    try do
      String.split(email, "@") |> Enum.at(0)
    rescue
      _ -> email
    end
  end
end
