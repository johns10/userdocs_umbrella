defmodule UserDocsWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :userdocs_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {UserDocsWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :mnesia]
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
      {:phoenix, "~> 1.5.7"},
      {:phoenix_ecto, "~> 4.2"},
      {:phoenix_live_view, "~> 0.15.4"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.3", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.0"},
      {:pow, "~> 1.0.22"},
      {:uuid, "~> 1.1"},
      {:dialyxir, "~> 0.5.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:cors_plug, "~> 2.0"},
      {:pbkdf2_elixir, "~> 1.0"},
      {:phoenix_slime, "~> 0.13.1"},
      {:userdocs, in_umbrella: true},

      {:waffle, "~> 1.1.3"},
      {:waffle_ecto, "~> 0.0.9"},
      {:ex_aws, "~> 2.1.2"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
