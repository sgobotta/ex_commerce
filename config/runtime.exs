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

  case System.get_env("DATABASE_URL") do
    nil ->
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

    database_url ->
      :ok = Logger.info("Using DATABASE_URL as Postgrex connection protocol.")

      config :ex_commerce, ExCommerce.Repo,
        ssl: true,
        url: database_url
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
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "5000"),
    server: true,
    http: [
      port: String.to_integer(System.get_env("PORT") || "5000"),
      transport_options: [socket_opts: [:inet6]]
    ],
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
