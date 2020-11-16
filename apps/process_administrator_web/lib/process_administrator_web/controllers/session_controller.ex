defmodule ProcessAdministratorWeb.SessionController do
  use ProcessAdministratorWeb, :controller

  def new(conn, _params) do
    changeset = Pow.Plug.change_user(conn)

    redirect(conn, to: Routes.index_path(conn, :index))
  end

  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.index_path(conn, :index))

      {:error, conn} ->
        changeset = Pow.Plug.change_user(conn, conn.params["user"])

        conn
        |> put_flash(:info, "Invalid email or password")
        |> redirect(to: Routes.index_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> redirect(to: Routes.index_path(conn, :index))
  end
end
