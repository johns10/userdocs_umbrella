defmodule UserDocsWeb.Pow.Routes do
  @moduledoc """
  Contains the redirect routes for pow
  """
  use Pow.Phoenix.Routes
  alias UserDocsWeb.Router.Helpers, as: Routes

  def after_registration_path(conn) do
    Routes.signup_index_path(conn, :edit, conn.assigns.current_user)
  end
end
