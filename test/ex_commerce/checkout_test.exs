defmodule ExCommerce.CheckoutTest do
  @moduledoc false
  use ExCommerce.DataCase

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.OrderItem

  require Decimal

  describe "checkout" do
    alias ExCommerce.Checkout.{Cart, CartServer}

    alias ExCommerce.Offerings.{
      Catalogue,
      CatalogueItem,
      CatalogueItemOption,
      CatalogueItemOptionGroup,
      CatalogueItemVariant,
      Relations
    }

    alias ExCommerce.{
      CatalogueItemOptionGroupsFixtures,
      CatalogueItemOptionsFixtures,
      CatalogueItemsFixtures,
      CatalogueItemVariantsFixtures,
      CataloguesFixtures,
      Offerings
    }

    setup do
      %Catalogue{
        id: catalogue_id,
        brand_id: brand_id
      } = CataloguesFixtures.create()

      %CatalogueItemOptionGroup{id: catalogue_item_option_group_id} =
        catalogue_item_option_group =
        CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})

      %CatalogueItemOption{id: catalogue_item_option_id} =
        CatalogueItemOptionsFixtures.create(%{
          brand_id: brand_id,
          catalogue_item_option_group_id: catalogue_item_option_group_id
        })

      %CatalogueItem{id: catalogue_item_id} =
        CatalogueItemsFixtures.create(%{brand_id: brand_id})

      # Relate CatalogueItem with CatalogueItemOptionGroup
      %Relations.CatalogueItemOptionGroupItem{} =
        Offerings.RelationsFixtures.catalogue_item_option_group_item_fixture(%{
          catalogue_item_option_group_id: catalogue_item_option_group_id,
          catalogue_item_id: catalogue_item_id
        })

      %CatalogueItemVariant{id: variant_id} =
        variant =
        CatalogueItemVariantsFixtures.create(%{
          catalogue_item_id: catalogue_item_id
        })

      cart_id = Cart.generate_id("some session id", catalogue_id)
      %Cart{} = cart = Cart.new(cart_id)

      catalogue_item_option_group =
        ExCommerce.Repo.preload(
          catalogue_item_option_group,
          options: [:catalogue_item_variant]
        )

      %Ecto.Changeset{} =
        order_item =
        Cart.OrderItem.changeset(
          %Cart.OrderItem{
            variants: [variant],
            available_option_groups: %{
              values: [catalogue_item_option_group],
              rules: []
            }
          },
          %{
            catalogue_item_id: catalogue_item_id,
            option_groups: %{
              catalogue_item_option_group_id => %{
                "valid?" => true,
                "value" => [catalogue_item_option_id]
              }
            },
            quantity: 2,
            variant_id: variant_id
          }
        )

      %{cart: cart, order_item: order_item}
    end

    @tag :wip
    test "add_to_order/2 adds an order item to a new order", %{
      cart: %Cart{} = cart,
      order_item: %Ecto.Changeset{} = order_item
    } do
      # Setup
      %Cart{server: server} = Checkout.add_to_order(cart, order_item)

      # Exercise
      %Cart.Order{order_items: order_items} = CartServer.get_order(server)

      # Verify
      assert length(order_items) == 1

      %Cart.OrderItem{quantity: quantity, price: price} =
        ^order_item = Enum.at(order_items, 0)

      assert quantity == 2
      assert Decimal.is_decimal(price)
    end

    test "from_cart_order/1 returns an #{Order} struct" do
    end
  end

  describe "orders" do
    alias ExCommerce.{
      BrandsFixtures,
      CataloguesFixtures,
      ShopsFixtures
    }

    alias ExCommerce.Checkout.{Order, OrderFixtures, OrderItemFixtures}
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
        shop: ShopsFixtures.create(%{brand_id: brand_id})
      }
    end

    @tag :wip
    test "list_orders/0 returns all orders" do
      %Order{} = order = OrderFixtures.create()
      assert Checkout.list_orders() == [order]
    end

    @tag :wip
    test "get_order!/1 returns the order with given id" do
      %Order{id: order_id} = order = OrderFixtures.create()
      assert Checkout.get_order!(order_id) == order
    end

    @tag :wip
    test "create_order/1 with valid data creates an order", %{
      brand: %Brand{id: brand_id},
      catalogue: %Catalogue{id: catalogue_id},
      shop: %Shop{id: shop_id}
    } do
      valid_attrs =
        Map.merge(@valid_attrs, %{
          brand_id: brand_id,
          catalogue_id: catalogue_id,
          shop_id: shop_id
        })

      assert {:ok,
              %Order{
                brand_id: ^brand_id,
                catalogue_id: ^catalogue_id,
                shop_id: ^shop_id
              }} = Checkout.create_order(valid_attrs)
    end

    @tag :wip
    test "create_order/1 with order_items creates an order", %{
      brand: %Brand{id: brand_id},
      catalogue: %Catalogue{id: catalogue_id},
      shop: %Shop{id: shop_id}
    } do
      valid_attrs =
        Map.merge(@valid_attrs, %{
          brand_id: brand_id,
          catalogue_id: catalogue_id,
          shop_id: shop_id
        })

      assert {:ok,
              %Order{
                brand_id: ^brand_id,
                catalogue_id: ^catalogue_id,
                shop_id: ^shop_id
              }} = Checkout.create_order(valid_attrs)
    end

    @tag :wip
    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checkout.create_order(@invalid_attrs)
    end

    @tag :wip
    test "update_order/2 with valid data updates the order" do
      %Order{} = order = OrderFixtures.create()

      assert {:ok, %Order{}} = Checkout.update_order(order, @update_attrs)
    end

    @tag :wip
    test "update_order/2 with invalid data returns error changeset" do
      %Order{id: order_id} = order = OrderFixtures.create()

      assert {:error, %Ecto.Changeset{}} =
               Checkout.update_order(order, @invalid_attrs)

      assert order == Checkout.get_order!(order_id)
    end

    @tag :wip
    test "delete_order/1 deletes the order" do
      %Order{id: order_id} = order = OrderFixtures.create()
      assert {:ok, %Order{}} = Checkout.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Checkout.get_order!(order_id) end
    end

    @tag :wip
    test "change_order/1 returns an order changeset" do
      %Order{} = order = OrderFixtures.create()
      assert %Ecto.Changeset{} = Checkout.change_order(order)
    end
  end
end
