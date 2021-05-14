defmodule UserDocsWeb.API.Auth.Context do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  alias UserDocs.{ Repo, Repo }

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(%{ assigns: %{ current_user: current_user }}) do
    %{current_user: current_user}
  end
end
