defmodule UserDocsWeb.SessionController do
  use UserDocsWeb, :controller

  def new(conn, _params) do
    changeset = Pow.Plug.change_user(conn)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    IO.puts("CREAETE")
    IO.inspect(conn)

    { "referer", url} =
      conn
      |> Map.get(:req_headers)
      |> Enum.filter(fn({k,v}) -> k == "referer" end)
      |> Enum.at(0)

    { "origin", origin} =
      conn
      |> Map.get(:req_headers)
      |> Enum.filter(fn({k,v}) -> k == "origin" end)
      |> Enum.at(0)

    path = String.replace(url, origin, "")

    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: path)

      {:error, conn} ->
        changeset = Pow.Plug.change_user(conn, conn.params["user"])

        conn
        |> put_flash(:info, "Invalid email or password")
        |> redirect(to: path)
    end
  end

  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
