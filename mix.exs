defmodule ExCommerce.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_commerce,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      # Docs
      name: "Ex Commerce",
      source_url: "https://github.com/sgobotta/ex_commerce",
      docs: [
        main: "ExCommerce",
        extras: ["README.md"]
      ]
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
  defp elixirc_paths(_env), do: ["lib", "priv/repo/seeds"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Code quality and Testing
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14", only: [:test]},
      {:git_hooks, "~> 0.6.2", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev], runtime: false},
      # Documentation
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      # Phoenix default apps
      {:phoenix, "~> 1.6.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.1.0"},
      {:phoenix_live_reload, "~> 1.3.3", only: :dev},
      {:phoenix_live_dashboard, "~> 0.6.2"},
      {:phoenix_live_view, "~> 0.17.5"},
      {:floki, ">= 0.30.0"},
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.18"},
      {:bcrypt_elixir, "~> 2.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      # Email apps
      {:bamboo, "~> 2.2.0"},
      # i18n and l10n
      {:ex_cldr, "~> 2.25"},
      {:ex_cldr_numbers, "~> 2.24"},
      # Web Helpers
      {:phoenix_inline_svg, "~> 1.4"},
      # Assets handling deps
      {:cloudex,
       git: "https://github.com/sgobotta/cloudex.git", branch: "main"},
      # Others
      {:decimal, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      # Setup the whole application
      setup: ["deps.get", "deps.compile", "compile", "setup.ecto", "setup.web"],
      "setup.ecto": [
        "ecto.drop",
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seeds.exs"
      ],
      "setup.web": [
        "cmd npm install --prefix assets",
        "cmd npm run deploy --prefix assets",
        "phx.digest"
      ],
      # Run code checks
      check: [
        "check.format",
        "check.credo",
        "check.dialyzer"
      ],
      "check.format": ["format --check-formatted", "eslint"],
      "check.credo": ["credo --strict"],
      "check.dialyzer": ["dialyzer --format dialyxir"],
      eslint: ["cmd npm run eslint --prefix assets"],
      "eslint.fix": ["cmd npm run eslint-fix --prefix assets"],
      # Reset database and deps
      reset: ["ecto.drop", "deps.clean --all"],
      "reset.ecto": [
        "ecto.drop",
        "ecto.create",
        "ecto.migrate",
        "run priv/repo/seeds.exs"
      ],
      # Run tests
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      # Build the web client
      "assets.deploy": ["esbuild default --minify", "phx.digest"]
    ]
  end
end
