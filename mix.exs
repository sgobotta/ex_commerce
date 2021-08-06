defmodule ExCommerce.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
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

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp deps do
    [
      # Code quality and Testing
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14", only: [:test]},
      {:git_hooks, "~> 0.6.2", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev], runtime: false},
      # Documentation
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  #
  # Aliases listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp aliases do
    [
      # Rin `mix install in all child apps
      install: ["deps.get", "cmd mix install"],
      # Run `mix setup` in all child apps
      setup: ["cmd mix setup", "deps.compile", "compile"],
      # Run code checks
      check: [
        # Run `mix lint` in all child apps
        "check.format",
        "check.credo",
        "check.dialyzer"
      ],
      "check.format": ["cmd mix lint"],
      "check.credo": ["credo --strict"],
      "check.dialyzer": ["dialyzer --format dialyxir"],
      # Reset applications
      reset: ["cmd mix reset", "setup"],
      "reset.ecto": ["cmd mix reset.ecto"]
    ]
  end
end
