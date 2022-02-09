defmodule ExCommerce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExCommerce.Repo,
      # Start the Telemetry supervisor
      ExCommerceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExCommerce.PubSub},
      # Start the Endpoint (http/https)
      ExCommerceWeb.Endpoint
      # Start a worker by calling: ExCommerce.Worker.start_link(arg)
      # {ExCommerce.Worker, arg}
    ]

    opts = [strategy: :one_for_one, name: ExCommerce.Supervisor]
    Supervisor.start_link(children, opts)
  end

    # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ExCommerceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
