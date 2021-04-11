defmodule UserDocs.MixProject do
  use Mix.Project

  def project do
    [
      app: :userdocs,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {UserDocs.Application, []},
      extra_applications: [:logger, :runtime_tools, :mnesia, :image64]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix_pubsub, "~> 2.0"},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:pow, "~> 1.0.21"},
      {:image64, "~> 0.0.1"},
      {:uuid, "~> 1.1"},
      {:mogrify, "~> 0.8.0"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:state_handlers, in_umbrella: true},
      {:cloak_ecto, "~> 1.1.1"},
      {:waffle, "~> 1.1.3"},
      {:waffle_ecto, "~> 0.0.9"},
      {:ex_aws, "~> 2.1.7"},
      {:ex_aws_s3, "~> 2.1.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
