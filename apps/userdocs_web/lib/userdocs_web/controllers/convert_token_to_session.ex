defmodule UserDocsWeb.TokenToSessionController do
  use UserDocsWeb, :controller

  alias UserDocs.Users

  def new(conn, _) do
    user = conn.assigns[:current_user]
    if user do # passing Bearer token
      user = Users.get_user!(user.id)
      config = Pow.Plug.fetch_config(conn)
      {conn, user} = Pow.Plug.Session.create(conn, user, config)
      conn
      |> Pow.Plug.Session.do_create(user, config)
      |> send_resp(:ok, "Session Created")
    end
  end
end
