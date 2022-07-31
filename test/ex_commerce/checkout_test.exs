defmodule ExCommerce.CheckoutTest do
  @moduledoc false
  use ExCommerce.DataCase

  alias ExCommerce.Checkout

  describe "order_items" do
    alias ExCommerce.Checkout.OrderItem

    import ExCommerce.CheckoutFixtures

    @invalid_attrs %{
      catalogue_item_id: nil,
      variant_id: nil,
      price: nil,
      quantity: nil
    }

    test "list_order_items/0 returns all order_items" do
      order_item = order_item_fixture()
      assert Checkout.list_order_items() == [order_item]
    end

    test "get_order_item!/1 returns the order_item with given id" do
      order_item = order_item_fixture()
      assert Checkout.get_order_item!(order_item.id) == order_item
    end

    test "create_order_item/1 with valid data creates a order_item" do
      valid_attrs = %{
        catalogue_item_id: "some catalogue_item_id",
        variant_id: "some variant_id",
        quantity: 1,
        price: ExCommerceNumeric.format_price(32.2)
      }

      assert {:ok, %OrderItem{} = order_item} =
               Checkout.create_order_item(valid_attrs)

      assert order_item.catalogue_item_id == "some catalogue_item_id"
      assert order_item.variant_id == "some variant_id"
    end

    test "create_order_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Checkout.create_order_item(@invalid_attrs)
    end

    test "update_order_item/2 with valid data updates the order_item" do
      order_item = order_item_fixture()

      update_attrs = %{
        catalogue_item_id: "some updated catalogue_item_id",
        variant_id: "some updated variant_id",
        quantity: 2
      }

      assert {:ok, %OrderItem{} = order_item} =
               Checkout.update_order_item(order_item, update_attrs)

      assert order_item.catalogue_item_id == "some updated catalogue_item_id"
      assert order_item.variant_id == "some updated variant_id"
    end

    test "update_order_item/2 with invalid data returns error changeset" do
      order_item = order_item_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Checkout.update_order_item(order_item, @invalid_attrs)

      assert order_item == Checkout.get_order_item!(order_item.id)
    end

    test "delete_order_item/1 deletes the order_item" do
      order_item = order_item_fixture()
      assert {:ok, %OrderItem{}} = Checkout.delete_order_item(order_item)

      assert_raise Ecto.NoResultsError, fn ->
        Checkout.get_order_item!(order_item.id)
      end
    end

    test "change_order_item/1 returns a order_item changeset" do
      order_item = order_item_fixture()
      assert %Ecto.Changeset{} = Checkout.change_order_item(order_item)
    end
  end

  describe "orders" do
    alias ExCommerce.{BrandsFixtures, CataloguesFixtures, ShopsFixtures}
    alias ExCommerce.Checkout.Order
    alias ExCommerce.Marketplaces.{Brand, Shop}
    alias ExCommerce.Offerings.Catalogue

    import ExCommerce.CheckoutFixtures

    @valid_attrs %{}

    @invalid_attrs %{
      brand_id: nil,
      shop_id: nil,
      catalogue_id: nil
    }

    setup do
      %Brand{id: brand_id} = brand = BrandsFixtures.create()

      %{
        brand: brand,
        catalogue: CataloguesFixtures.create(%{brand_id: brand_id}),
        shop: ShopsFixtures.create(%{brand_id: brand_id})
      }
    end

    test "list_orders/0 returns all orders" do
      %Order{} = order = order_fixture()
      assert Checkout.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      %Order{id: order_id} = order = order_fixture()
      assert Checkout.get_order!(order_id) == order
    end

    test "create_order/1 with valid data creates a order", %{
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

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checkout.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      %Order{} = order = order_fixture()
      update_attrs = %{}

      assert {:ok, %Order{}} = Checkout.update_order(order, update_attrs)
    end

    test "update_order/2 with invalid data returns error changeset" do
      %Order{id: order_id} = order = order_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Checkout.update_order(order, @invalid_attrs)

      assert order == Checkout.get_order!(order_id)
    end

    test "delete_order/1 deletes the order" do
      %Order{id: order_id} = order = order_fixture()
      assert {:ok, %Order{}} = Checkout.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Checkout.get_order!(order_id) end
    end

    test "change_order/1 returns a order changeset" do
      %Order{} = order = order_fixture()
      assert %Ecto.Changeset{} = Checkout.change_order(order)
    end
  end
end
