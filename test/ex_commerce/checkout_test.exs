defmodule ExCommerce.CheckoutTest do
  @moduledoc false
  use ExCommerce.ContextCases.CheckoutCase
  use ExCommerce.DataCase

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.Order
  alias ExCommerce.Marketplaces

  require Decimal

  describe "update_cart_order/2" do
    alias ExCommerce.Checkout.Cart
    alias ExCommerce.Checkout.Cart.Order

    setup [
      :create_catalogue,
      :create_shop,
      :relate_shop_catalogue,
      :create_catalogue_item_option_groups,
      :create_catalogue_item_options,
      :create_catalogue_items,
      :relate_catalogue_item_option_groups_items,
      :create_catalogue_item_variants,
      :create_cart,
      :create_order,
      :create_order_changeset
    ]

    test "returns a #{Cart} with an updated #{Cart.Order}",
         %{
           cart: %Cart{} = cart,
           cart_order_changeset: %Ecto.Changeset{} = cart_order_changeset
         } do
      # Setup
      %Ecto.Changeset{
        changes: %{
          brand_id: brand_id,
          catalogue_id: catalogue_id,
          shop_id: shop_id
        }
      } = cart_order_changeset

      # Exercise
      %Cart{} = cart = Checkout.update_cart_order(cart, cart_order_changeset)

      # Verify
      %Cart{
        order: %Cart.Order{
          brand_id: ^brand_id,
          catalogue_id: ^catalogue_id,
          shop_id: ^shop_id
        }
      } = cart
    end
  end

  describe "add_to_order/2" do
    alias ExCommerce.Checkout.{Cart, CartServer}

    setup [
      :create_catalogue,
      :create_shop,
      :relate_shop_catalogue,
      :create_catalogue_item_option_groups,
      :create_catalogue_item_options,
      :create_catalogue_items,
      :relate_catalogue_item_option_groups_items,
      :create_catalogue_item_variants,
      :create_cart,
      :create_order,
      :create_order_changeset
    ]

    test "adds an #{Cart.OrderItem} to a new #{Cart.Order}", %{
      cart: %Cart{} = cart,
      order_item: %Ecto.Changeset{} = order_item
    } do
      # Setup
      %Cart{server: server} = do_add_to_order(cart, order_item)

      # Exercise
      %Cart.Order{order_items: order_items} = CartServer.get_order(server)

      # Verify
      assert length(order_items) == 1

      %Cart.OrderItem{quantity: quantity, price: price} =
        Enum.at(order_items, 0)

      assert quantity == 2
      assert Decimal.is_decimal(price)
    end
  end

  describe "from_cart_order/2" do
    setup [
      :create_catalogue,
      :create_shop,
      :relate_shop_catalogue,
      :create_catalogue_item_option_groups,
      :create_catalogue_item_options,
      :create_catalogue_items,
      :relate_catalogue_item_option_groups_items,
      :create_catalogue_item_variants,
      :create_cart,
      :create_order,
      :create_order_changeset
    ]

    test "with invalid Order attributes returns an invalid #{Order} changeset",
         %{
           brand: %Marketplaces.Brand{name: brand_name},
           cart: %Cart{} = cart,
           cart_order_changeset: %Ecto.Changeset{} = cart_order_changeset,
           catalogue: %Offerings.Catalogue{name: catalogue_name},
           shop: %Marketplaces.Shop{name: shop_name}
         } do
      # Setup
      cart_order_changeset =
        Cart.Order.changeset(
          cart_order_changeset,
          Cart.OrderFixtures.invalid_attrs()
        )

      %Cart{order: %Cart.Order{} = cart_order} =
        do_update_cart_order(cart, cart_order_changeset)

      from_cart_order_params = %{
        brand_name: brand_name,
        catalogue_name: catalogue_name,
        shop_name: shop_name
      }

      # Exercise
      {:error, %Ecto.Changeset{valid?: valid?, errors: _errors}} =
        do_from_cart_order(cart_order, from_cart_order_params)

      # Verify
      refute valid?
    end

    test "with invalid params returns an invalid #{Order} changeset",
         %{
           cart: %Cart{} = cart,
           cart_order_changeset: %Ecto.Changeset{} = cart_order_changeset
         } do
      # Setup
      cart_order_changeset =
        Cart.Order.changeset(
          cart_order_changeset,
          Cart.OrderFixtures.valid_attrs()
        )

      %Cart{order: %Cart.Order{} = cart_order} =
        do_update_cart_order(cart, cart_order_changeset)

      from_cart_order_params = %{
        brand_name: nil,
        catalogue_name: nil,
        shop_name: nil
      }

      # Exercise
      {:error, %Ecto.Changeset{valid?: valid?, errors: _errors}} =
        do_from_cart_order(cart_order, from_cart_order_params)

      # Verify
      refute valid?
    end

    test "returns an #{Order} struct",
         %{
           brand: %Marketplaces.Brand{name: brand_name},
           cart: %Cart{} = cart,
           cart_order_changeset: %Ecto.Changeset{} = cart_order_changeset,
           catalogue: %Offerings.Catalogue{name: catalogue_name},
           order_item: %Ecto.Changeset{} = order_item,
           shop: %Marketplaces.Shop{name: shop_name}
         } do
      # Setup
      attrs = Cart.OrderFixtures.valid_attrs()

      cart_order_changeset =
        Cart.Order.changeset(
          cart_order_changeset,
          attrs
        )

      %Cart{} = cart = do_update_cart_order(cart, cart_order_changeset)

      %Cart{order: %Cart.Order{} = cart_order} =
        do_add_to_order(cart, order_item)

      from_cart_order_params = %{
        brand_name: brand_name,
        catalogue_name: catalogue_name,
        shop_name: shop_name
      }

      # Exercise
      {:ok, %Order{order_items: order_items}} =
        do_from_cart_order(cart_order, from_cart_order_params)

      # Verify
      assert length(order_items) == 1
    end
  end

  defp do_update_cart_order(%Cart{} = cart, %Ecto.Changeset{} = changeset),
    do: Checkout.update_cart_order(cart, changeset)

  defp do_add_to_order(%Cart{} = cart, %Ecto.Changeset{} = changeset),
    do: Checkout.add_to_order(cart, changeset)

  defp do_from_cart_order(%Cart.Order{} = cart_order, params),
    do: Checkout.from_cart_order(cart_order, params)

  describe "orders" do
    alias ExCommerce.{
      BrandsFixtures,
      CataloguesFixtures,
      ShopsFixtures
    }

    alias ExCommerce.Checkout.{Order, OrderFixtures}
    alias ExCommerce.Marketplaces.{Brand, Shop}
    alias ExCommerce.Offerings.Catalogue

    @valid_attrs OrderFixtures.valid_attrs()
    @update_attrs OrderFixtures.update_attrs()
    @invalid_attrs OrderFixtures.invalid_attrs()

    setup do
      %Brand{id: brand_id} = brand = BrandsFixtures.create()

      %{
        brand: brand,
        catalogue: CataloguesFixtures.create(%{brand_id: brand_id}),
        order_item_attrs: order_item_attrs(),
        shop: ShopsFixtures.create(%{brand_id: brand_id})
      }
    end

    test "list_orders/0 returns all orders", %{
      order_item_attrs: order_item_attrs
    } do
      %Order{} =
        order =
        OrderFixtures.create(%{
          order_items: [order_item_attrs]
        })

      assert Checkout.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id", %{
      order_item_attrs: order_item_attrs
    } do
      %Order{id: order_id} =
        order =
        OrderFixtures.create(%{
          order_items: [order_item_attrs]
        })

      assert Checkout.get_order!(order_id) == order
    end

    test "create_order/1 with valid data creates an order", %{
      brand: %Brand{id: brand_id},
      catalogue: %Catalogue{id: catalogue_id},
      order_item_attrs: order_item_attrs,
      shop: %Shop{id: shop_id}
    } do
      valid_attrs =
        Map.merge(@valid_attrs, %{
          brand_id: brand_id,
          catalogue_id: catalogue_id,
          order_items: [order_item_attrs],
          shop_id: shop_id
        })

      assert {:ok,
              %Order{
                brand_id: ^brand_id,
                catalogue_id: ^catalogue_id,
                shop_id: ^shop_id
              }} = Checkout.create_order(valid_attrs)
    end

    test "create_order/1 with order_items creates an order", %{
      brand: %Brand{id: brand_id},
      catalogue: %Catalogue{id: catalogue_id},
      order_item_attrs: order_item_attrs,
      shop: %Shop{id: shop_id}
    } do
      valid_attrs =
        Map.merge(@valid_attrs, %{
          brand_id: brand_id,
          catalogue_id: catalogue_id,
          order_items: [order_item_attrs],
          shop_id: shop_id
        })

      assert {:ok,
              %Order{
                brand_id: ^brand_id,
                catalogue_id: ^catalogue_id,
                shop_id: ^shop_id
              }} = Checkout.create_order(valid_attrs)
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checkout.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order", %{
      order_item_attrs: order_item_attrs
    } do
      %Order{} =
        order =
        OrderFixtures.create(%{
          order_items: [order_item_attrs]
        })

      assert {:ok, %Order{}} = Checkout.update_order(order, @update_attrs)
    end

    test "update_order/2 with invalid data returns error changeset", %{
      order_item_attrs: order_item_attrs
    } do
      %Order{id: order_id} =
        order = OrderFixtures.create(%{order_items: [order_item_attrs]})

      assert {:error, %Ecto.Changeset{}} =
               Checkout.update_order(order, @invalid_attrs)

      assert order == Checkout.get_order!(order_id)
    end

    test "delete_order/1 deletes the order", %{
      order_item_attrs: order_item_attrs
    } do
      %Order{id: order_id} =
        order = OrderFixtures.create(%{order_items: [order_item_attrs]})

      assert {:ok, %Order{}} = Checkout.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Checkout.get_order!(order_id) end
    end

    test "change_order/1 returns an order changeset", %{
      order_item_attrs: order_item_attrs
    } do
      %Order{} =
        order = OrderFixtures.create(%{order_items: [order_item_attrs]})

      assert %Ecto.Changeset{} = Checkout.change_order(order)
    end
  end
end
