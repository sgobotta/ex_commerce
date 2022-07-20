defmodule ExCommerce.Checkout.CartSupervisorTest do
  @moduledoc """
  Cart Supervisor tests
  """
  use ExCommerce.DataCase
  use ExUnit.Case

  describe "cart_supervisor" do
    alias ExCommerce.Checkout.CartSupervisor

    @supervisor_name :cart_supervisor_test

    setup do
      pid = start_supervised!({CartSupervisor, [name: @supervisor_name]})

      %{pid: pid}
    end

    test "child_spec/2 starts a cart supervisor", %{pid: pid} do
      assert valid_pid?(pid)
    end

    test "start_child/2 starts a cart server with args", %{pid: pid} do
      {:ok, pid} = start_child(pid, id: "some cart id")

      assert valid_pid?(pid)
    end

    test "list_children/1 returns a list of pids", %{pid: pid} do
      {:ok, child_pid} = start_child(pid, id: "some cart id")

      assert Enum.member?(list_children(pid), child_pid)
    end

    test "get_child/2 returns a pid and state", %{pid: pid} do
      cart_id = "some cart id"

      {:ok, child_pid} = start_child(pid, id: cart_id)

      {^child_pid, %{id: ^cart_id} = state} = get_child(pid, cart_id)

      assert is_map(state)
    end

    test "terminate_child/2 shuts down a pid", %{pid: pid} do
      cart_id = "some cart id"

      {:ok, child_pid} = start_child(pid, id: cart_id)

      assert valid_pid?(child_pid)

      :ok = terminate_child(pid, child_pid)
      refute valid_pid?(child_pid)
    end

    defp start_child(pid, args), do: CartSupervisor.start_child(pid, args)

    defp list_children(pid), do: CartSupervisor.list_children(pid)

    defp get_child(pid, cart_id),
      do: CartSupervisor.get_child(pid, cart_id)

    defp terminate_child(pid, child_pid),
      do: CartSupervisor.terminate_child(pid, child_pid)
  end

  defp valid_pid?(pid), do: is_pid(pid) and Process.alive?(pid)
end
