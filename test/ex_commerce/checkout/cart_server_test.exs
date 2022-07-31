defmodule ExCommerce.Checkout.CartServerTest do
  @moduledoc """
  Cart Server tests
  """
  use ExCommerce.DataCase
  use ExCommerce.RuntimeCase, ratio: 1 / 32
  use ExUnit.Case

  alias ExCommerce.Checkout.CartServer

  describe "cart_server lifecycle" do
    test "a server automatically terminates after a certain period" do
      pid = start_server(ratio(2))
      assert is_pid(pid)

      :ok = sleep_with_ratio(1)
      assert Process.alive?(pid)

      :ok = sleep_with_ratio(1)
      refute Process.alive?(pid)
    end

    test "a server timeout restarts when called" do
      # Setup
      server_timeout = 2
      pid = start_server(ratio(server_timeout))
      assert is_pid(pid)

      # Spawn a task that keeps the server alive
      %Task{} =
        task =
        spawn_with_interval(fn pid -> do_get_order(pid) end, [pid], 2, ratio(1))

      # Verifies the server is still alive
      :ok = sleep_with_ratio(server_timeout)
      assert Process.alive?(pid)

      # Awaits til server terminates and verifies
      :ok = Task.await(task)
      :ok = sleep_with_ratio(server_timeout)
      refute Process.alive?(pid)
    end

    defp spawn_with_interval(fun, args, times, interval) do
      Task.async(fn ->
        for _n <- 1..times do
          apply(fun, args)
          :timer.sleep(interval)
        end

        :ok
      end)
    end

    defp start_server(timeout) do
      cart_id = "some id"
      on_start = fn _state -> :ok end

      start_supervised!(
        {CartServer, [on_start: on_start, id: cart_id, timeout: timeout]}
      )
    end
  end

  describe "cart_server client interface" do
    setup do
      cart_id = "some id"
      on_start = fn _state -> :ok end
      pid = start_supervised!({CartServer, [on_start: on_start, id: cart_id]})

      %{pid: pid, id: cart_id}
    end

    test "get_order/2 returns an order from the current state", %{pid: pid} do
      response = do_get_order(pid)
      assert response == %{}
    end

    test "set_order/2 returns :ok", %{pid: pid} do
      response = do_set_order(pid, %{some: "value"})
      assert response == :ok
    end
  end

  defp do_get_order(pid), do: CartServer.get_order(pid)

  defp do_set_order(pid, order), do: CartServer.set_order(pid, order)

  describe "cart_server implementation" do
    setup do
      on_start = fn _state -> :ok end
      cart_id = "some id"
      state = CartServer.initial_state(on_start: on_start, id: cart_id)

      %{state: state}
    end

    test "handle_call/3 :get_order replies with an order", %{state: state} do
      %{order: order} = state
      response = CartServer.handle_call(:get_order, self(), state)

      {:reply, ^order, %{order: ^order} = _state} = response
    end

    test "handle_cast/2 {:set_order, order} updates an order and does not reply",
         %{state: state} do
      order = %{some: "value"}

      response = CartServer.handle_cast({:set_order, order}, state)

      {:noreply, %{order: ^order} = _state} = response
    end
  end
end
