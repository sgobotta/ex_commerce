use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# ------------------------------------------------------------------------------
# Ex Commerce configuration
#

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ex_commerce, ExCommerce.Repo,
  username: System.get_env("DB_USERNAME", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  database: "ex_commerce_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  timeout: :infinity

# ------------------------------------------------------------------------------
# Ex Commerce Web configuration
#

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_commerce_web, ExCommerceWeb.Endpoint,
  http: [port: 4002],
  server: false

# ------------------------------------------------------------------------------
# Ex Commerce Assets configuration
#
config :ex_commerce_assets,
  driver: :test

# ------------------------------------------------------------------------------
# Email configuration
#

config :ex_commerce, from_email: "test@ex.commerce"

config :ex_commerce, ExCommerce.Mailer, adapter: Bamboo.LocalAdapter

# ------------------------------------------------------------------------------
# Cloudex configuration
#

config :cloudex,
  api_key: "some-api-key",
  secret: "some-secret",
  cloud_name: "some-cloud-name"

# ------------------------------------------------------------------------------
# Shared configuration
#

# Print only warnings and errors during test
config :logger, level: :warn
