defmodule ExCommerceNotifications.Parsers.OrderTest do
  @moduledoc false
  use ExCommerce.DataCase

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
    Offerings,
    OrderFixtures,
    OrderItemFixtures
  }

  alias ExCommerce.Checkout.Order

  alias ExCommerceNotifications.Parsers

  import ExCommerceNumeric

  describe "order parser" do
    setup do
      # ------------------------------------------------------------------------
      # Create a catalogue to get a brand id
      #
      %Catalogue{
        brand_id: brand_id
      } = CataloguesFixtures.create()

      # ------------------------------------------------------------------------
      # Create Groups that holds options
      #
      %CatalogueItemOptionGroup{id: catalogue_item_option_group_id_1} =
        catalogue_item_option_group_1 =
        CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})

      %CatalogueItemOptionGroup{id: catalogue_item_option_group_id_2} =
        catalogue_item_option_group_2 =
        CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})

      # ------------------------------------------------------------------------
      # Create a Options for the groups
      #
      %CatalogueItemOption{id: catalogue_item_option_id_1} =
        CatalogueItemOptionsFixtures.create(%{
          brand_id: brand_id,
          catalogue_item_option_group_id: catalogue_item_option_group_id_1
        })

      %CatalogueItemOption{id: catalogue_item_option_id_2} =
        CatalogueItemOptionsFixtures.create(%{
          brand_id: brand_id,
          catalogue_item_option_group_id: catalogue_item_option_group_id_1
        })

      %CatalogueItemOption{id: catalogue_item_option_id_3} =
        CatalogueItemOptionsFixtures.create(%{
          brand_id: brand_id,
          catalogue_item_option_group_id: catalogue_item_option_group_id_2
        })

      # ------------------------------------------------------------------------
      # Create an Item to add the Group to
      #
      %CatalogueItem{id: catalogue_item_id} =
        CatalogueItemsFixtures.create(%{brand_id: brand_id})

      # Relate the Groups to the Item
      %Relations.CatalogueItemOptionGroupItem{} =
        Offerings.RelationsFixtures.catalogue_item_option_group_item_fixture(%{
          catalogue_item_option_group_id: catalogue_item_option_group_id_1,
          catalogue_item_id: catalogue_item_id
        })

      %Relations.CatalogueItemOptionGroupItem{} =
        Offerings.RelationsFixtures.catalogue_item_option_group_item_fixture(%{
          catalogue_item_option_group_id: catalogue_item_option_group_id_2,
          catalogue_item_id: catalogue_item_id
        })

      # ------------------------------------------------------------------------
      # Create a Variant for the Item
      #
      %CatalogueItemVariant{id: variant_id} =
        variant =
        CatalogueItemVariantsFixtures.create(%{
          catalogue_item_id: catalogue_item_id
        })

      # ------------------------------------------------------------------------
      # Preload Groups fields and nested fields
      #
      %CatalogueItemOptionGroup{} =
        catalogue_item_option_group_1 =
        ExCommerce.Repo.preload(catalogue_item_option_group_1,
          options: [
            catalogue_item_variant: [:catalogue_item]
          ]
        )

      %CatalogueItemOptionGroup{} =
        catalogue_item_option_group_2 =
        ExCommerce.Repo.preload(catalogue_item_option_group_2,
          options: [
            catalogue_item_variant: [:catalogue_item]
          ]
        )

      order_items =
        for _n <- 1..3,
            do:
              OrderItemFixtures.build(%{
                catalogue_item_id: catalogue_item_id,
                variants: [variant],
                available_option_groups: %{
                  values: [
                    catalogue_item_option_group_1,
                    catalogue_item_option_group_2
                  ],
                  rules: []
                },
                option_groups: %{
                  catalogue_item_option_group_id_1 => %{
                    "valid?" => true,
                    "value" => [
                      catalogue_item_option_id_1,
                      catalogue_item_option_id_2
                    ]
                  },
                  catalogue_item_option_group_id_2 => %{
                    "valid?" => true,
                    "value" => catalogue_item_option_id_3
                  }
                },
                variant_id: variant_id
              })
              |> ExCommerce.Checkout.preload_order_item([
                :catalogue_item,
                :variant
              ])

      %Order{} =
        order =
        OrderFixtures.build(%{
          address: "Some address",
          buyer_name: "Some buyer name",
          note: "Some notes",
          order_items: order_items
        })

      %{order: order}
    end

    test "parse_order/1 returns a map that represents a parsed order", %{
      order: %Order{} = order
    } do
      %{
        address: "Some address",
        buyer_name: "Some buyer name",
        note: "Some notes",
        items: items
      } = do_parse_order(order)

      for item <- items, do: assert_valid_order_item!(item)
    end

    defp assert_valid_order_item!(order_item) do
      assert order_item.name == "some name"
      assert order_item.quantity == 1
      assert order_item.total_price == format_price(42)
      assert order_item.variant == "some type"
      assert order_item.variant_price == format_price(120.5)

      assert_valid_order_item_groups!(order_item.option_groups)

      :ok
    end

    defp assert_valid_order_item_groups!(option_groups) do
      assert length(option_groups) == 2

      for option_group <- option_groups,
          do: assert_valid_option_group!(option_group)
    end

    defp assert_valid_option_group!(option_group) do
      assert option_group.name == "some name"

      for option <- option_group.options, do: assert_valid_option!(option)
    end

    defp assert_valid_option!(option) do
      assert option.discount_price == Decimal.new("67.48")
      assert option.item_name == "some name"
      assert option.variant_name == "some type"
      assert option.variant_price == Decimal.new("120.50")
    end

    defp do_parse_order(%Order{} = order),
      do: Parsers.Order.parse(order)
  end
end
