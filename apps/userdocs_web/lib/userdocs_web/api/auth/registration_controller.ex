defmodule UserDocsWeb.API.RegistrationController do
  use UserDocsWeb, :controller

  alias Ecto.Changeset
  alias Plug.Conn
  alias UserDocsWeb.ErrorHelpers

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
      {:ok, _user, conn} ->
        json(conn, %{data: %{access_token: conn.private[:api_access_token], renewal_token: conn.private[:api_renewal_token]}})

      {:error, changeset, conn} ->
        errors = Changeset.traverse_errors(changeset, &ErrorHelpers.translate_error/1)

        conn
        |> put_status(500)
        |> json(%{error: %{status: 500, message: "Couldn't create user", errors: errors}})
    end
  end

  def resend_confirmation_email(conn, _params) do
    case PowEmailConfirmation.Plug.pending_email_change?(conn) do
      true ->
        send_confirmation_email(conn)

        conn
        |> put_flash(:info, "E-mail sent, please check your inbox.")
        |> redirect(to: Routes.registration_path(conn, :edit))

      false ->
        conn
        |> put_flash(:info, "E-mail has already been confirmed.")
        |> redirect(to: Routes.registration_path(conn, :edit))
    end
  end

  defp send_confirmation_email(conn) do
    user = Pow.Plug.current_user(conn)

    PowEmailConfirmation.Phoenix.ControllerCallbacks.send_confirmation_email(user, conn)
  end
end
