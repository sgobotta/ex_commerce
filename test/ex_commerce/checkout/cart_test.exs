defmodule ExCommerce.Checkout.CartTest do
  @moduledoc """
  Cart tests
  """
  use ExCommerce.DataCase
  use ExUnit.Case

  describe "cart" do
    alias ExCommerce.Checkout.{Cart, CartSupervisor}

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
      order = %Cart.Order{}
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

      order = %Cart.Order{buyer_name: name}

      %Cart{order: %Cart.Order{buyer_name: ^name}} =
        new(id)
        |> Cart.set_order(order)
    end

    test "get_order/2 returns the current Order in the Cart" do
      id = generate_id()
      name = "Some name"

      order = %Cart.Order{buyer_name: name}

      %Cart{order: %Cart.Order{buyer_name: ^name}} =
        cart =
        new(id)
        |> Cart.set_order(order)

      %Cart.Order{buyer_name: ^name} = Cart.get_order(cart)
    end

    test "get_order_price/1 returns the Cart total price expressed in Decimal" do
      id = generate_id()

      %Cart{order: %Cart.Order{price: price}} =
        cart =
        %Cart{order: %Cart.Order{order_items: [%Cart.OrderItem{}]}} =
        new(id)
        |> Cart.add_to_order(%Cart.OrderItem{
          temp_id: "123",
          price: Decimal.new("42.37")
        })

      ^price = Cart.get_order_price(cart)
    end

    test "get_total_items/1 returns the number of order_items in the cart" do
      id = generate_id()

      %Cart{order: %Cart.Order{}} =
        cart =
        %Cart{order: %Cart.Order{order_items: [%Cart.OrderItem{}]}} =
        new(id)
        |> Cart.add_to_order(%Cart.OrderItem{
          temp_id: "123",
          price: Decimal.new("42.37")
        })

      assert Cart.get_total_items(cart) == 1
    end

    test "add_to_order/2 returns a new Cart struct with an updated order" do
      id = generate_id()

      %Cart{order: %Cart.Order{order_items: [], price: initial_price}} =
        cart = new(id)

      assert Decimal.eq?(initial_price, Decimal.new("0"))

      order_item_price = Decimal.new("42.37")

      %Cart{
        order: %Cart.Order{
          order_items: [%Cart.OrderItem{}],
          price: updated_price
        }
      } = Cart.add_to_order(cart, %Cart.OrderItem{price: order_item_price})

      assert Decimal.eq?(updated_price, order_item_price)
    end

    test "remove_from_order/2 returns a new Cart struct with an updated order" do
      id = generate_id()

      %Cart{
        order: %Cart.Order{order_items: [], price: %Decimal{} = initial_price}
      } = cart = new(id)

      assert Decimal.eq?(initial_price, Decimal.new("0"))

      order_item_price = Decimal.new("42.37")

      %Cart{
        order: %Cart.Order{
          order_items: [%Cart.OrderItem{}],
          price: %Decimal{} = updated_price
        }
      } =
        cart =
        Cart.add_to_order(cart, %Cart.OrderItem{
          temp_id: "123",
          price: order_item_price
        })

      assert Decimal.eq?(updated_price, order_item_price)

      %Cart{order: %Cart.Order{order_items: [], price: ^initial_price}} =
        Cart.remove_from_order(cart, "123")
    end

    test "remove_from_order/2 returns a new Cart struct with no updated order on invalid temp_id" do
      id = generate_id()

      %Cart{} =
        cart =
        %Cart{order: %Cart.Order{order_items: [%Cart.OrderItem{}]}} =
        new(id)
        |> Cart.add_to_order(%Cart.OrderItem{temp_id: "123"})

      %Cart{order: %Cart.Order{order_items: [%Cart.OrderItem{}]}} =
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
