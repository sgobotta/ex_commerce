import Config

require Logger

if config_env() == :prod do
  # ----------------------------------------------------------------------------
  # Ex Commerce configuration
  #

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :ex_commerce, ExCommerce.Repo,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6,
    show_sensitive_data_on_connection_error: false

  host = System.fetch_env!("APP_HOST")
  port = String.to_integer(System.get_env("PORT", "443"))

  case System.get_env("STAGE") do
    "local" ->
      :ok =
        Logger.warn(
          "Ignoring variable DATABASE_URL as Postgrex connection protocol, proceding with default tcp connection."
        )

      config(:ex_commerce, ExCommerce.Repo,
        database: System.get_env("DB_DATABASE"),
        username: System.fetch_env!("DB_USERNAME"),
        password: System.fetch_env!("DB_PASSWORD"),
        hostname: System.fetch_env!("DB_HOSTNAME")
      )

      config :ex_commerce, ExCommerceWeb.Endpoint,
        http: [
          port: port,
          transport_options: [socket_opts: [:inet6]]
        ],
        url: [host: host, port: port]

    _stage ->
      :ok = Logger.info("Using DATABASE_URL as Postgrex connection protocol.")

      config :ex_commerce, ExCommerce.Repo,
        ssl: true,
        url: System.fetch_env!("DATABASE_URL")

      config :ex_commerce, ExCommerceWeb.Endpoint,
        http: [
          # Enable IPv6 and bind on all interfaces.
          # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
          # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
          # for details about using IPv6 vs IPv4 and loopback vs public addresses.
          # ip: {0, 0, 0, 0, 0, 0, 0, 0},
          port: {:system, "PORT"}
        ],
        url: [scheme: "https", host: host, port: 443]
  end

  # ----------------------------------------------------------------------------
  # Ex Commerce Web configuration
  #

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :ex_commerce, ExCommerceWeb.Endpoint,
    server: true,
    secret_key_base: secret_key_base

  # ----------------------------------------------------------------------------
  # Email configuration
  #
  config :ex_commerce, from_email: System.fetch_env!("EX_COMMERCE_FROM_EMAIL")

  config :ex_commerce, ExCommerce.Mailer,
    api_key: System.fetch_env!("SENDGRID_API_KEY")

  # ----------------------------------------------------------------------------
  # Cloudex configuration
  #
  config :cloudex,
    api_key: System.fetch_env!("CLOUDEX_API_KEY"),
    secret: System.fetch_env!("CLOUDEX_SECRET"),
    cloud_name: System.fetch_env!("CLOUDEX_CLOUD_NAME")
end
