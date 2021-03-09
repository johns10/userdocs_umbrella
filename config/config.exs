# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :userdocs,
  namespace: UserDocs,
  ecto_repos: [UserDocs.Repo]

config :userdocs_web,
  namespace: UserDocsWeb,
  ecto_repos: [UserDocs.Repo],
  generators: [context_app: :userdocs]

# Configures the endpoint
config :userdocs_web, UserDocsWeb.Endpoint,
  url: [ host: "localhost" ],
  secret_key_base: "uYNO0z5S7TuzLxe//ihPPyhDY+9/juUgfW4fFJkw+nKlP/omZmmVMmcIWuBolrzY",
  render_errors: [view: UserDocsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: UserDocs.PubSub,
  live_view: [signing_salt: "EkPV4O8j"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: [
    "chrome-extension://mkbbhaeofgjbbhopopbjnjjjfbbnaone",
    "http://localhost",
    "https://app.user-docs.com",
  ],
  max_age: 86400,
  methods: ["GET", "PUT", "POST", "OPTIONS"]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine,
  slimleex: PhoenixSlime.LiveViewEngine

config :userdocs_web, :pow,
  user: UserDocs.Users.User,
  repo: UserDocs.Repo,
  cache_store_backend: Pow.Store.Backend.MnesiaCache,
  backend: Pow.Store.Backend.MnesiaCache,
  routes_backend: UserDocsWeb.Pow.Routes

config :userdocs, :userdocs_s3,
  uploads_dir: "uploads"

#Because I can't get config without an App name
config :userdocs, :waffle,
  storage: Waffle.Storage.S3, # or Waffle.Storage.Local
  bucket: System.get_env("AWS_BUCKET_NAME") # if using S3

# If using S3:
config :userdocs, :ex_aws,
  json_codec: Jason,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  region: System.get_env("AWS_REGION")

config :waffle,
  storage: Waffle.Storage.S3, # or Waffle.Storage.Local
  bucket: System.get_env("AWS_BUCKET_NAME") # if using S3

# If using S3:
config :ex_aws,
  json_codec: Jason,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  region: System.get_env("AWS_REGION")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

if Mix.env() in [:dev, :test] do
end
