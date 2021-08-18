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
  defp elixirc_paths(:integration), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bodyguard, "~> 2.4"},
      {:phoenix_pubsub, "~> 2.0.0"},
      {:ecto_sql, "~> 3.5"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      {:pow, "~> 1.0.21"},
      {:image64, "~> 0.0.1"},
      {:uuid, "~> 1.1"},
      {:mogrify, "~> 0.8.0"},
      {:cloak_ecto, "~> 1.1.1"},
      {:waffle, "~> 1.1.4"},
      {:waffle_ecto, "~> 0.0.9"},
      {:ex_aws, "~> 2.2.1"},
      {:ex_aws_s3, "~> 2.1.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"},
      {:inflex, "~> 2.0.0"},
      {:bamboo, "~> 2.2.0"},
      {:state_handlers, in_umbrella: true},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
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
