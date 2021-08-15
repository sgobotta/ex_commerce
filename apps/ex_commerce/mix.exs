defmodule ExCommerce.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_commerce,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExCommerce.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "priv/repo/seeds", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/repo/seeds"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.0"},
      # Email configuration
      {:bamboo, "~> 2.2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # Run lint tasks
      lint: ["format.check"],
      "format.check": ["format --check-formatted"],
      # Deps install
      install: ["deps.get"],
      # Setup deps and database
      setup: ["install", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      # Reset deps and database
      reset: ["ecto.drop", "deps.reset"],
      "deps.reset": ["deps.clean --all"],
      "reset.ecto": ["ecto.drop", "ecto.setup"],
      # Run tests
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
