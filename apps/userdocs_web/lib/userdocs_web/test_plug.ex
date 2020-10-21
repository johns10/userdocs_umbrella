defmodule UserDocsWeb.TestPlug do
  import Plug.Conn, only: [put_session: 3]

  def init(_opts), do: nil

  def call(conn, _opts) do
    IO.puts("Test Plug")

    conn
  end
end
