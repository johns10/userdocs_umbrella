# web/controllers/user_controller
defmodule UserDocsWeb.CSRFController do
  use UserDocsWeb, :controller
  def index(conn, _params) do
    json conn, Map.get(get_session(conn), "_csrf_token")
  end
end
