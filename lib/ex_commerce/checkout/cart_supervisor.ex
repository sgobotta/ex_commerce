defmodule ExCommerce.Checkout.CartSupervisor do
  @moduledoc """
  Specific implementation for the Cart Supervisor
  """
  use DynamicSupervisor

  require Logger

  alias ExCommerce.Checkout.CartServer

  @doc """
  Given a keyword of args, initialises the dynamic Cart Supervisor.
  """
  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(init_arg) do
    name = Keyword.get(init_arg, :name, __MODULE__)
    init_arg = Keyword.delete(init_arg, :name)

    DynamicSupervisor.start_link(__MODULE__, init_arg, name: name)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Given a reference and some arguments starts a `CartServer` child and returns
  it's pid.
  """
  @spec start_child(module(), keyword()) :: {:ok, pid()}
  def start_child(supervisor \\ __MODULE__, [id: _id] = args) do
    DynamicSupervisor.start_child(supervisor, {CartServer, args})
  end

  @doc """
  Given a reference returns all supervisor children pids.
  """
  @spec list_children(module()) :: [pid()]
  def list_children(supervisor \\ __MODULE__) do
    DynamicSupervisor.which_children(supervisor)
    |> Enum.filter(fn
      {_id, pid, :worker, _modules} when is_pid(pid) -> true
      _child -> false
    end)
    |> Enum.map(fn {_id, pid, :worker, _modules} -> pid end)
  end

  @doc """
  Given a reference and a cart id, returns `nil` or a tuple where the first
  component is a `CartServer` pid and the second component the cart server
  state.
  """
  @spec get_child(module(), binary()) :: {pid(), map()} | nil
  def get_child(supervisor \\ __MODULE__, child_id) do
    list_children(supervisor)
    |> Enum.map(&{&1, CartServer.get_state(&1)})
    |> Enum.find(fn {_pid, state} -> state.id == child_id end)
  end

  @doc """
  Given a reference and a child pid, terminates a `CartServer` process.
  """
  @spec terminate_child(module(), pid()) :: :ok | {:error, :not_found}
  def terminate_child(supervisor \\ __MODULE__, pid) do
    DynamicSupervisor.terminate_child(supervisor, pid)
  end
end
