defmodule UserDocsWeb.Presence do
  use Phoenix.Presence,
    otp_app: :userdocs_web,
    pubsub_server: UserDocs.PubSub
end
