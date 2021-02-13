defmodule UserDocsWeb.SessionController do
  use UserDocsWeb, :controller

  def new(conn, _params) do
    changeset = Pow.Plug.change_user(conn)

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: maybe_referer_path(conn))

      {:error, conn} ->
        conn
        |> put_flash(:info, "Invalid email or password")
        |> redirect(to: maybe_referer_path(conn))
    end
  end

  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> redirect(to: maybe_referer_path(conn))
  end

  def maybe_referer_path(conn) do
    referers =
      conn
      |> Map.get(:req_headers)
      |> Enum.filter(fn({k,_}) -> k == "referer" end)

    origins =
      conn
      |> Map.get(:req_headers)
      |> Enum.filter(fn({k,_}) -> k == "origin" end)

    case referers do
      [ _ | _ ] -> referer_path(referers, origins)
      [] -> "/index.html"
    end
  end

  def referer_path(referers, origins) do
    { "referer", url } = Enum.at(referers, 0)
    { "origin", origin } = Enum.at(origins, 0)
    String.replace(url, origin, "")
  end
end
