defmodule DocumentEditorWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DocumentEditorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DocumentEditorWeb.PubSub},
      # Start the Endpoint (http/https)
      DocumentEditorWeb.Endpoint
      # Start a worker by calling: DocumentEditorWeb.Worker.start_link(arg)
      # {DocumentEditorWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DocumentEditorWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DocumentEditorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
