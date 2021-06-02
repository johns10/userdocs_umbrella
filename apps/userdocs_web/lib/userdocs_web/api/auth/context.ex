defmodule UserDocsWeb.API.Auth.Context do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(%{ assigns: %{ current_user: current_user }}) do
    %{current_user: current_user}
  end
end
