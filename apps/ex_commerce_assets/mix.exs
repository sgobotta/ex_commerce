defmodule ExCommerceAssets.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_commerce_assets,
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cloudex]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cloudex, git: "https://github.com/sgobotta/cloudex.git", branch: "main"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
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
