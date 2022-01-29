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
  defp elixirc_paths(:test), do: ["lib", "priv", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Default Phoenix deps
      {:phoenix, "~> 1.6.5"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0"},
      {:phoenix_html, "~> 3.1.0"},
      {:phoenix_live_reload, "~> 1.3.3", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6.2"},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      # Client bundling
      # Umbrella deps
      {:ex_commerce, in_umbrella: true},
      {:ex_commerce_assets, in_umbrella: true},
      {:ex_commerce_numeric, in_umbrella: true},
      # Helpers
      {:phoenix_inline_svg, "~> 1.4"}
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
      "assets.deploy": [
        "cmd npm install --prefix assets",
        "cmd npm run deploy --prefix assets",
        "phx.digest"
      ],
      install: [],
      # Setup deps and database
      setup: ["install", "assets.deploy"],
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
