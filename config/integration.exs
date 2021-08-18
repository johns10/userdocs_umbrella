use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :pbkdf2_elixir, :rounds, 1

# Configure your database
config :userdocs, UserDocs.Repo,
  username: "postgres",
  password: "postgres",
  database: "userdocs_integration#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :userdocs, UserDocs.Mailer,
  adapter: Bamboo.TestAdapter

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :userdocs_web, UserDocsWeb.Endpoint,
  http: [port: 4000],
  https: [
    port: 4002,
    cipher_suite: :strong,
    certfile: "priv/cert/user-docs.com.crt",
    keyfile: "priv/cert/user-docs.com.key"
  ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  server: true

#config :logger, level: :warn
config :logger, :console, format: "[$level] $message\n"


# Watch static and templates for browser reloading.
config :userdocs_web, UserDocsWeb.Endpoint,
  live_reload: [
    patterns: [
      # ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/userdocs_web/(live|views)/.*(ex)$",
      ~r"lib/userdocs_web/templates/.*(eex|slim|slime|slimleex)$"
    ]
  ]
