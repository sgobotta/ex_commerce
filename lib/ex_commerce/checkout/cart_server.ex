defmodule ExCommerce.Checkout.CartServer do
  @moduledoc """
  The Cart Server implementation
  """
  use GenServer, restart: :transient

  require Logger

  @timeout :timer.seconds(3600)

  @type order :: map()
  @type state :: %{
          :id => binary(),
          :order => order(),
          :timeout => pos_integer(),
          :timer_ref => reference() | nil
        }

  @doc """
  Given a keyword of arguments, starts a #{GenServer} process linked to the
  current process.
  """
  @spec start_link(keyword()) :: {:ok, pid()}
  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args)
  end

  @doc """
  Given a pid, returns the current order.
  """
  @spec get_order(pid()) :: order()
  def get_order(pid) do
    GenServer.call(pid, :get_order)
  end

  @doc """
  Given a #pid and an order, sets the order to the current state.
  Always returns `:ok`.
  """
  @spec set_order(pid(), order()) :: :ok
  def set_order(pid, order) do
    GenServer.cast(pid, {:set_order, order})
  end

  @doc """
  Given a keyword of args returns a new map that represents the #{__MODULE__}
  state.
  """
  @spec initial_state(keyword()) :: state()
  def initial_state(opts) do
    %{
      id: Keyword.fetch!(opts, :id),
      order: %{},
      timeout: Keyword.get(opts, :timeout, @timeout),
      timer_ref: nil
    }
  end

  @impl GenServer
  def init(init_args) do
    :ok =
      Logger.info(
        "#{__MODULE__} :: Started process with pid=#{inspect(self())}, args=#{inspect(init_args)}"
      )

    {:ok, initial_state(init_args),
     {:continue, Keyword.fetch!(init_args, :on_start)}}
  end

  @impl GenServer
  def handle_continue(on_start, state) do
    :ok = on_start.(state)

    {:noreply, set_timeout(state)}
  end

  @impl GenServer
  def handle_call(:get_order, _from, state) do
    {:reply, state.order, set_timeout(state)}
  end

  @impl GenServer
  def handle_cast({:set_order, order}, state) do
    state =
      set_timeout(state)
      |> Map.put(:order, order)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:kill, state) do
    :ok =
      Logger.info(
        "#{__MODULE__} :: Terminating process with pid=#{inspect(self())}"
      )

    true = Process.exit(self(), :normal)

    {:noreply, state}
  end

  defp set_timeout(%{timeout: timeout, timer_ref: nil} = state) do
    %{state | timer_ref: Process.send_after(self(), :kill, timeout)}
  end

  defp set_timeout(%{timeout: timeout, timer_ref: timer_ref} = state) do
    _timeleft = Process.cancel_timer(timer_ref)

    %{state | timer_ref: Process.send_after(self(), :kill, timeout)}
  end
end
