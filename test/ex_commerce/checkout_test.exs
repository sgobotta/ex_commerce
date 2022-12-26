defmodule ExCommerce.CheckoutTest do
  @moduledoc false
  use ExCommerce.DataCase

  alias ExCommerce.Checkout

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

    test "add_to_order/2 adds an order item to a new order" do
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

      %Cart{server: server} = Checkout.add_to_order(cart, order_item)

      %Cart.Order{order_items: order_items} = CartServer.get_order(server)

      assert length(order_items) == 1
      %Cart.OrderItem{} = order_item = Enum.at(order_items, 0)
      assert order_item.quantity == 2
      assert order_item.catalogue_item_id == catalogue_item_id
      assert Decimal.is_decimal(order_item.price)
      assert order_item.variant_id == variant_id
    end
  end

  # describe "order_items" do
  #   alias ExCommerce.Checkout.OrderItem

  #   alias ExCommerce.Marketplaces.Brand

  #   alias ExCommerce.{
  #     BrandsFixtures,
  #     OrderItemFixtures
  #   }

  #   @invalid_attrs %{
  #     catalogue_item_id: nil,
  #     variant_id: nil,
  #     price: nil,
  #     quantity: nil
  #   }

  #   @tag :skip
  #   test "list_order_items/0 returns all order_items" do
  #     order_item = OrderItemFixtures.create()
  #     assert Checkout.list_order_items() == [order_item]
  #   end

  #   @tag :skip
  #   test "get_order_item!/1 returns the order_item with given id" do
  #     order_item = OrderItemFixtures.create()
  #     assert Checkout.get_order_item!(order_item.id) == order_item
  #   end

  #   @tag :skip
  #   test "create_order_item/1 with valid data creates a order_item" do
  #     %OrderItem{
  #       catalogue_item_id: catalogue_item_id,
  #       variant_id: variant_id
  #     } = OrderItemFixtures.create()

  #     valid_attrs = %{
  #       catalogue_item_id: catalogue_item_id,
  #       variant_id: variant_id,
  #       quantity: 1,
  #       price: ExCommerceNumeric.format_price(32.2)
  #     }

  #     assert {:ok, %OrderItem{} = order_item} =
  #              Checkout.create_order_item(valid_attrs)

  #     assert order_item.catalogue_item_id == catalogue_item_id
  #     assert order_item.variant_id == variant_id
  #   end

  #   @tag :skip
  #   test "create_order_item/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} =
  #              Checkout.create_order_item(@invalid_attrs)
  #   end

  #   @tag :skip
  #   test "update_order_item/2 with valid data updates the order_item" do
  #     %OrderItem{} = order_item = OrderItemFixtures.create()

  #     %OrderItem{
  #       catalogue_item_id: catalogue_item_id,
  #       variant_id: variant_id
  #     } = OrderItemFixtures.create()

  #     update_attrs = %{
  #       catalogue_item_id: catalogue_item_id,
  #       variant_id: variant_id,
  #       quantity: 2
  #     }

  #     assert {:ok, %OrderItem{} = order_item} =
  #              Checkout.update_order_item(order_item, update_attrs)

  #     assert order_item.catalogue_item_id == catalogue_item_id
  #     assert order_item.variant_id == variant_id
  #   end

  #   @tag :skip
  #   test "update_order_item/2 with invalid data returns error changeset" do
  #     order_item = OrderItemFixtures.create()

  #     assert {:error, %Ecto.Changeset{}} =
  #              Checkout.update_order_item(order_item, @invalid_attrs)

  #     assert order_item == Checkout.get_order_item!(order_item.id)
  #   end

  #   @tag :skip
  #   test "delete_order_item/1 deletes the order_item" do
  #     order_item = OrderItemFixtures.create()
  #     assert {:ok, %OrderItem{}} = Checkout.delete_order_item(order_item)

  #     assert_raise Ecto.NoResultsError, fn ->
  #       Checkout.get_order_item!(order_item.id)
  #     end
  #   end

  #   @tag :skip
  #   test "change_order_item/1 returns a order_item changeset" do
  #     order_item = OrderItemFixtures.create()
  #     assert %Ecto.Changeset{} = Checkout.change_order_item(order_item)
  #   end

  #   alias ExCommerce.Offerings.CatalogueItem
  #   alias ExCommerce.Offerings.CatalogueItemVariant

  #   @tag :skip
  #   test "preload_order_item/2 returns a preloadad order_item" do
  #     %OrderItem{} = order_item = OrderItemFixtures.create()

  #     %OrderItem{
  #       catalogue_item: %CatalogueItem{} = catalogue_item,
  #       variant: %CatalogueItemVariant{} = variant
  #     } = Checkout.preload_order_item(order_item, [:catalogue_item, :variant])

  #     assert catalogue_item != nil
  #     assert variant != nil
  #   end
  # end

  # describe "orders" do
  #   alias ExCommerce.{
  #     BrandsFixtures,
  #     CataloguesFixtures,
  #     OrderFixtures,
  #     ShopsFixtures
  #   }

  #   alias ExCommerce.Checkout.Order
  #   alias ExCommerce.Marketplaces.{Brand, Shop}
  #   alias ExCommerce.Offerings.Catalogue

  #   @valid_attrs OrderFixtures.valid_attrs()

  #   @invalid_attrs OrderFixtures.invalid_attrs()

  #   setup do
  #     %Brand{id: brand_id} = brand = BrandsFixtures.create()

  #     %{
  #       brand: brand,
  #       catalogue: CataloguesFixtures.create(%{brand_id: brand_id}),
  #       shop: ShopsFixtures.create(%{brand_id: brand_id})
  #     }
  #   end

  #   @tag :skip
  #   test "list_orders/0 returns all orders" do
  #     %Order{} = order = OrderFixtures.create()
  #     assert Checkout.list_orders() == [order]
  #   end

  #   @tag :skip
  #   test "get_order!/1 returns the order with given id" do
  #     %Order{id: order_id} = order = OrderFixtures.create()
  #     assert Checkout.get_order!(order_id) == order
  #   end

  #   @tag :skip
  #   test "create_order/1 with valid data creates a order", %{
  #     brand: %Brand{id: brand_id},
  #     catalogue: %Catalogue{id: catalogue_id},
  #     shop: %Shop{id: shop_id}
  #   } do
  #     valid_attrs =
  #       Map.merge(@valid_attrs, %{
  #         brand_id: brand_id,
  #         catalogue_id: catalogue_id,
  #         shop_id: shop_id
  #       })

  #     assert {:ok,
  #             %Order{
  #               brand_id: ^brand_id,
  #               catalogue_id: ^catalogue_id,
  #               shop_id: ^shop_id
  #             }} = Checkout.create_order(valid_attrs)
  #   end

  #   @tag :skip
  #   test "create_order/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} =
  #       Checkout.create_order(@invalid_attrs)
  #   end

  #   @tag :skip
  #   test "update_order/2 with valid data updates the order" do
  #     %Order{} = order = OrderFixtures.create()
  #     update_attrs = %{}

  #     assert {:ok, %Order{}} = Checkout.update_order(order, update_attrs)
  #   end

  #   @tag :skip
  #   test "update_order/2 with invalid data returns error changeset" do
  #     %Order{id: order_id} = order = OrderFixtures.create()

  #     assert {:error, %Ecto.Changeset{}} =
  #              Checkout.update_order(order, @invalid_attrs)

  #     assert order == Checkout.get_order!(order_id)
  #   end

  #   @tag :skip
  #   test "delete_order/1 deletes the order" do
  #     %Order{id: order_id} = order = OrderFixtures.create()
  #     assert {:ok, %Order{}} = Checkout.delete_order(order)
  #     assert_raise Ecto.NoResultsError, fn -> Checkout.get_order!(order_id)
  # end
  #   end

  #   @tag :skip
  #   test "change_order/1 returns a order changeset" do
  #     %Order{} = order = OrderFixtures.create()
  #     assert %Ecto.Changeset{} = Checkout.change_order(order)
  #   end

  #   @tag :skip
  #   test "preload_order/2 returns a preloadad order" do
  #     %Order{} = order = OrderFixtures.create()

  #     %Order{order_items: order_items} =
  #       Checkout.preload_order(order, [:order_items])

  #     assert order_items == []
  #   end
  # end
end
