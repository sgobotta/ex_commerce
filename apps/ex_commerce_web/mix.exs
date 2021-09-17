defmodule ExCommerceWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_commerce_web,
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
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ExCommerceWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :ex_cldr, :ex_cldr_numbers]
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
      # Default Phoenix deps
      {:phoenix, "~> 1.5.9"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_view, "~> 0.15.1"},
      {:floki, ">= 0.30.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      # Umbrella deps
      {:ex_commerce, in_umbrella: true},
      # Helpers
      {:phoenix_inline_svg, "~> 1.4"},
      # Authentication
      {:phx_gen_auth, "~> 0.7", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # Run lint tasks
      lint: ["format.check", "eslint"],
      "format.check": ["format --check-formatted"],
      eslint: ["cmd npm run eslint --prefix assets"],
      "eslint.fix": ["cmd npm run eslint-fix --prefix assets"],
      # Setup deps
      install: ["deps.get", "cmd npm install --prefix assets"],
      # Setup deps and database
      setup: ["install"],
      # Reset deps
      reset: ["deps.reset"],
      "deps.reset": [
        "deps.clean --all",
        "cmd npm clean-install --prefix assets"
      ],
      "reset.ecto": [],
      # Run tests
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
