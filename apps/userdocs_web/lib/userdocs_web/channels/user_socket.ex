defmodule UserDocsWeb.UserSocket do
  use Phoenix.Socket

  require Logger

  ## Channels
  # channel "room:*", UserDocsWeb.RoomChannel
  channel "user:*", UserDocsWeb.UserChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    salt = Atom.to_string(UserDocsWeb.API.Auth.Plug)
    config = Application.get_env(:userdocs_web, :pow)
    conn = %Plug.Conn{secret_key_base: UserDocsWeb.Endpoint.config(:secret_key_base)}
           |> Pow.Plug.put_config(otp_app: :userdocs_web)

    case Pow.Plug.verify_token(conn, salt, token, config) do
      {:ok, _token} -> {:ok, socket}
      result ->
        Logger.error("Authentication Failed #{result}")
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     UserDocsWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
