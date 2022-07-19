defmodule ExCommerce.Checkout.CartSupervisor do
  @moduledoc """
  Specific implementation for the Cart Supervisor
  """
  use DynamicSupervisor

  require Logger

  alias ExCommerce.Checkout.CartServer

  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(init_arg) do
    {:ok, pid} =
      DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)

    :ok = Logger.info("#{__MODULE__} :: started with pid: #{inspect(pid)}")

    {:ok, pid}
  end

  @spec start_child(module(), keyword()) :: {:ok, pid()}
  def start_child(supervisor \\ __MODULE__, [id: _id] = args) do
    DynamicSupervisor.start_child(supervisor, {CartServer, args})
  end

  @spec list_children(module()) :: [pid()]
  def list_children(supervisor \\ __MODULE__) do
    DynamicSupervisor.which_children(supervisor)
    |> Enum.filter(fn
      {_id, pid, :worker, _modules} when is_pid(pid) -> true
      _child -> false
    end)
    |> Enum.map(fn {_id, pid, :worker, _modules} -> pid end)
  end

  @spec get_child(module(), binary()) :: {pid(), map()} | nil
  def get_child(supervisor \\ __MODULE__, child_id) do
    list_children(supervisor)
    |> Enum.map(&{&1, CartServer.get_state(&1)})
    |> Enum.find(fn {_pid, state} -> state.id == child_id end)
  end

  @spec terminate_child(module(), pid()) :: :ok | {:error, :not_found}
  def terminate_child(supervisor \\ __MODULE__, pid) do
    DynamicSupervisor.terminate_child(supervisor, pid)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
