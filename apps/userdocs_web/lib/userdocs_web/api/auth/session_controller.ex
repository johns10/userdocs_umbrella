defmodule UserDocsWeb.API.SessionController do
  use UserDocsWeb, :controller

  alias Plug.Conn

  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        response = %{
          data:
          %{
            access_token: conn.private.api_access_token,
            renewal_token: conn.private.api_renewal_token,
            user_id: conn.assigns.current_user.id
          }
        }
        json(conn, response)

      {:error, conn} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid email or password"}})
    end
  end

  @spec renew(Conn.t(), map()) :: Conn.t()
  def renew(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> UserDocsWeb.API.Auth.Plug.renew(config)
    |> case do
      {conn, nil} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})

      {conn, user} ->
        json(conn, %{data: %{
          access_token: conn.private.api_access_token,
          renewal_token: conn.private.api_renewal_token,
          user_id: user.id
        }})
    end
  end

  @spec delete(Conn.t(), map()) :: Conn.t()
  def delete(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> json(%{data: %{}})
  end
end
