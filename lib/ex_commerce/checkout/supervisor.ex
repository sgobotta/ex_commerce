defmodule ExCommerce.Checkout.Supervisor do
  @moduledoc """
  The Checkout Supervisor is a module-based sueprvisor in charge of
  initialising any supervisor related to the Checkout context.
  """
  use Supervisor

  alias ExCommerce.Checkout.CartSupervisor

  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Registry, keys: :unique, name: Registry.Cart},
      {CartSupervisor, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
