defmodule ExCommerce.Checkout.CartServer do
  @moduledoc """
  The Cart Server implementation
  """
  use GenServer, restart: :transient

  alias ExCommerce.Checkout.Cart

  require Logger

  @kill_after :timer.seconds(10)

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args)
  end

  def add_to_order(%Cart{server: pid}, order_item) do
    GenServer.call(pid, {:add_to_order, order_item})
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def initial_state(id: id) do
    %{
      id: id,
      order: %{},
      timer_ref: nil
    }
  end

  @impl GenServer
  def init(init_args) do
    :ok =
      Logger.info(
        "#{__MODULE__} :: started with pid: #{inspect(self())} args=#{inspect(init_args)}"
      )

    timer_ref = Process.send_after(self(), :kill, @kill_after)

    state =
      initial_state(init_args)
      |> Map.put(:timer_ref, timer_ref)

    {:ok, state}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    Logger.info("#{__MODULE__} :: :get_state state=#{inspect(state)}")

    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:add_to_order, order_item}, _from, state) do
    Logger.info(
      "#{__MODULE__} :: :add_to_order order_item=#{inspect(order_item)}"
    )

    state = %{state | order: order_item}

    {:reply, {:ok, state}, state}
  end

  @impl GenServer
  def handle_info(:kill, state) do
    :ok = Logger.info("#{__MODULE__} :: killed")

    true = Process.exit(self(), :normal)

    {:noreply, state}
  end
end
