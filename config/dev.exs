use Mix.Config

# ------------------------------------------------------------------------------
# Ex Commerce configuration
#

# Configure your database
config :ex_commerce, ExCommerce.Repo,
  username: System.get_env("DB_USERNAME", "postgres"),
  password: System.get_env("DB_PASSWORD", "postgres"),
  database: System.get_env("DB_DATABASE", "ex_commerce_dev"),
  hostname: System.get_env("DB_HOSTNAME", "localhost"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# ------------------------------------------------------------------------------
# Ex Commerce Web configuration
#

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :ex_commerce_web, ExCommerceWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch",
      "--watch-options-stdin",
      cd: Path.expand("../apps/ex_commerce_web/assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :ex_commerce_web, ExCommerceWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/ex_commerce_web/(live|views)/.*(ex)$",
      ~r"lib/ex_commerce_web/templates/.*(eex)$"
    ]
  ]

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# ------------------------------------------------------------------------------
# Email configuration
#

config :ex_commerce, from_email: "dev@ex.commerce"

config :ex_commerce, ExCommerce.Mailer, adapter: Bamboo.LocalAdapter

# ------------------------------------------------------------------------------
# Shared configuration
#

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configures git pre-push hook to run a general check
config :git_hooks,
  auto_install: true,
  verbose: true,
  hooks: [
    pre_push: [
      tasks: [
        {:mix_task, :check}
      ]
    ]
  ]
