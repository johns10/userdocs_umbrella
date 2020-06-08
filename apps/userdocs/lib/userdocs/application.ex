defmodule UserDocs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      UserDocs.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: UserDocs.PubSub}
      # Start a worker by calling: UserDocs.Worker.start_link(arg)
      # {UserDocs.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: UserDocs.Supervisor)
  end
end
