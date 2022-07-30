defmodule ExCommerce.Checkout.CartTest do
  @moduledoc """
  Cart tests
  """
  use ExCommerce.DataCase
  use ExUnit.Case

  describe "cart" do
    alias ExCommerce.Checkout.{Cart, CartSupervisor}

    @tag :wip
    test "generate_id/2 returns an encoded id" do
      session_id = "123"
      catalogue_id = Ecto.UUID.generate()

      cart_id = generate_id(session_id, catalogue_id)

      assert is_binary(cart_id)
      assert String.length(cart_id) == 64
    end

    @tag :wip
    test "new/1 returns a new Cart struct with a nil server" do
      id = generate_id()

      %Cart{id: ^id, server: nil} = new(id)
    end

    @tag :wip
    test "new/1 returns a new Cart struct with an existent server" do
      id = generate_id()
      {:ok, server_pid} = CartSupervisor.start_child(CartSupervisor, id: id)

      %Cart{id: ^id, server: ^server_pid} = new(id)
    end

    @tag :wip
    test "set_server/2 returns a new Cart struct with a server pid" do
      id = generate_id()
      self = self()

      %Cart{server: ^self} =
        new(id)
        |> Cart.set_server(self)
    end

    @tag :wip
    test "set_state/2 returns a new Cart struct with a state" do
      id = generate_id()

      %Cart{state: %{some: "value"}} =
        new(id)
        |> Cart.set_state(%{some: "value"})
    end

    defp generate_id do
      first_id = "123"
      second_id = Ecto.UUID.generate()

      generate_id(first_id, second_id)
    end

    defp generate_id(first_id, second_id),
      do: Cart.generate_id(first_id, second_id)

    defp new(id), do: Cart.new(id)
  end
end
