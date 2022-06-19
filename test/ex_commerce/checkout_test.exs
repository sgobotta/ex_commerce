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
end
