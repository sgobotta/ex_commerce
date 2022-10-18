defmodule ExCommerce.Checkout.CartTest do
  @moduledoc """
  Cart tests
  """
  use ExCommerce.DataCase
  use ExUnit.Case

  describe "cart" do
    alias ExCommerce.Checkout
    alias ExCommerce.Checkout.{Cart, CartSupervisor, Order, OrderItem}

    test "generate_id/2 returns an encoded id" do
      session_id = "123"
      catalogue_id = Ecto.UUID.generate()

      cart_id = generate_id(session_id, catalogue_id)

      assert is_binary(cart_id)
      assert String.length(cart_id) == 64
    end

    test "new/1 returns a new Cart struct with a nil server" do
      id = generate_id()

      %Cart{id: ^id, server: nil} = new(id)
    end

    test "new/1 returns a new Cart struct with an existent server" do
      id = generate_id()
      order = Checkout.preload_order(%Order{}, [:order_items])
      args = [id: id, order: order]
      {:ok, server_pid} = CartSupervisor.start_child(CartSupervisor, args)

      %Cart{id: ^id, server: ^server_pid} = new(id)
    end

    test "set_server/2 returns a new Cart struct with a server pid" do
      id = generate_id()
      self = self()

      %Cart{server: ^self} =
        new(id)
        |> Cart.set_server(self)
    end

    test "set_order/2 returns a new Cart struct with a new order" do
      id = generate_id()
      name = "Some name"

      order = %Order{buyer_name: name}

      %Cart{order: %Order{buyer_name: ^name}} =
        new(id)
        |> Cart.set_order(order)
    end

    test "get_order/2 returns the current Order in the Cart" do
      id = generate_id()
      name = "Some name"

      order = %Order{buyer_name: name}

      %Cart{order: %Order{buyer_name: ^name}} =
        cart =
        new(id)
        |> Cart.set_order(order)

      %Order{buyer_name: ^name} = Cart.get_order(cart)
    end

    test "add_to_order/2 returns a new Cart struct with an updated order" do
      id = generate_id()

      %Cart{order: %Order{order_items: [%OrderItem{}]}} =
        new(id)
        |> Cart.add_to_order(%OrderItem{})
    end

    test "remove_from_order/2 returns a new Cart struct with an updated order" do
      id = generate_id()

      %Cart{} =
        cart =
        %Cart{order: %Order{order_items: [%OrderItem{}]}} =
        new(id)
        |> Cart.add_to_order(%OrderItem{temp_id: "123"})

      %Cart{order: %Order{order_items: []}} =
        Cart.remove_from_order(cart, "123")
    end

    test "remove_from_order/2 returns a new Cart struct with no updated order on invalid temp_id" do
      id = generate_id()

      %Cart{} =
        cart =
        %Cart{order: %Order{order_items: [%OrderItem{}]}} =
        new(id)
        |> Cart.add_to_order(%OrderItem{temp_id: "123"})

      %Cart{order: %Order{order_items: [%OrderItem{}]}} =
        Cart.remove_from_order(cart, "456")
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
