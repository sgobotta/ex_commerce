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
