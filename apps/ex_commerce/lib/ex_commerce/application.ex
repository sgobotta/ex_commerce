defmodule ExCommerce.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ExCommerce.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExCommerce.PubSub}
      # Start a worker by calling: ExCommerce.Worker.start_link(arg)
      # {ExCommerce.Worker, arg}
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: ExCommerce.Supervisor
    )
  end
end
