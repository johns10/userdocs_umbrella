defmodule UserDocs.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def application do [applications: [:image64]] end

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      UserDocs.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: UserDocs.PubSub, adapter: Phoenix.PubSub.PG2}
      # Start a worker by calling: UserDocs.Worker.start_link(arg)
      # {UserDocs.Worker, arg}
    ]

    :pg2.create(UserDocs.PubSub)
    Supervisor.start_link(children, strategy: :one_for_one, name: UserDocs.Supervisor)
  end
end
