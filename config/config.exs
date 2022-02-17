# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :ex_commerce,
  ecto_repos: [ExCommerce.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :ex_commerce, ExCommerceWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    view: ExCommerceWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: ExCommerce.PubSub,
  live_view: [signing_salt: "M+Dyy4Zh"]

# Configures Phoenix Inline Svg
config :phoenix_inline_svg, default_collection: ""

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# ------------------------------------------------------------------------------
# i18n and l10n configuration
#

config :ex_cldr,
  default_backend: ExCommerceWeb.Cldr,
  json_library: Jason

# ------------------------------------------------------------------------------
# Misc configuration
#

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :mfa]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
