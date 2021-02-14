defmodule UserDocsWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      UserDocsWeb.Telemetry,
      # Start the Endpoint (http/https)
      UserDocsWeb.Endpoint,
      Pow.Store.Backend.MnesiaCache
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UserDocsWeb.Supervisor]
    :pg2.join(UserDocs.PubSub, self())
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    UserDocsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
