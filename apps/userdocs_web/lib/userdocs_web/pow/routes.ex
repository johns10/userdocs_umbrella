defmodule UserDocsWeb.Pow.Routes do
  @moduledoc """
  Contains the redirect routes for pow
  """
  use Pow.Phoenix.Routes
  alias UserDocsWeb.Router.Helpers, as: Routes

  def after_registration_path(conn) do
    Routes.signup_index_path(conn, :edit, conn.assigns.current_user)
  end
  def after_sign_in_path(conn) do
    pow_config = Application.get_env(:userdocs_web, :pow)
    {conn, _user} = UserDocsWeb.API.Auth.Plug.create(conn, conn.assigns.current_user, pow_config)
    Routes.page_path(conn, :index, logged_in: true,
      access_token: conn.private[:api_access_token],
      renewal_token: conn.private[:api_renewal_token]
    )
  end
  def after_sign_out_path(conn), do: Routes.pow_session_path(conn, :new)
  def user_not_authenticated_path(conn), do: Routes.pow_session_path(conn, :new)
end
