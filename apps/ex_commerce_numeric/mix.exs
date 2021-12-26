defmodule ExCommerceNumeric.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_commerce_numeric,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
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
      extra_applications: [:logger]
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
      # Others
      {:decimal, "~> 2.0"}
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
      setup: ["install"],
      # Reset deps and database
      reset: ["deps.reset"],
      "deps.reset": ["deps.clean --all"],
      "reset.ecto": [],
      # Run tests
      test: ["test"]
    ]
  end
end
