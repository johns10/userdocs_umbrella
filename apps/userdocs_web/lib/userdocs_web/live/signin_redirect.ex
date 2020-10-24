defmodule UserDocsWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias UserDocsWeb.Router.Helpers, as: Routes

  def after_sign_in_path(conn), do: Routes.process_administrator_index_path(conn, :index)
end
