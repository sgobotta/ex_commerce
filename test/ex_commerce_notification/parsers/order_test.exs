defmodule ExCommerceNotifications.Parsers.OrderTest do
  @moduledoc false
  use ExCommerce.DataCase

  alias ExCommerce.{
    CatalogueItemOptionGroupsFixtures,
    CatalogueItemOptionsFixtures,
    CatalogueItemsFixtures,
    CatalogueItemVariantsFixtures,
    CataloguesFixtures,
    Offerings,
    OrderFixtures,
    OrderItemFixtures
  }

  alias ExCommerce.Checkout.{Order, OrderItem}

  alias ExCommerceNotifications.Parsers

  import ExCommerceNumeric

  describe "order parser" do
    setup do
      %Order{id: order_id} =
        order =
        OrderFixtures.create(%{
          address: "Some address",
          buyer_name: "Some buyer name",
          note: "Some notes"
        })

      order_items =
        for _n <- 1..3,
            do:
              OrderItemFixtures.create(%{
                order_id: order_id
              })

      order =
        ExCommerce.Checkout.preload_order(order,
          order_items: [:catalogue_item, :variant]
        )

      %{order: order}
    end

    @tag :wip
    test "parse_order/1 returns a map that represents a parsed order", %{
      order: %Order{} = order
    } do
      %{
        address: "Some address",
        buyer_name: "Some buyer name",
        note: "Some notes",
        items: items
      } = do_parse_order(order)

      Enum.each(items, fn item ->
        :ok = valid_order_item?(item)
      end)
    end

    defp valid_order_item?(order_item) do
      assert order_item.name == "some name"
      assert order_item.quantity == 1
      assert order_item.total_price == format_price(42)
      assert order_item.variant == "some type"
      assert order_item.variant_price == format_price(120.5)
      assert order_item.option_groups == []

      :ok
    end

    defp do_parse_order(%Order{} = order),
      do: Parsers.Order.parse(order)
  end
end
