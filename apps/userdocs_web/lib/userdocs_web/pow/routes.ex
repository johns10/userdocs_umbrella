defmodule UserDocsWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias UserDocsWeb.Router.Helpers, as: Routes

  def after_registration_path(conn), do: Routes.signup_index_path(conn, :setup)
end
