defmodule ExCommerce.ContextCases.CheckoutCase do
  @moduledoc """
  This module defines the test case to be used by tests that require Checkout
  helpers.
  """

  # Long quote blocks are not allowed.
  # credo:disable-for-lines:174

  use ExUnit.CaseTemplate

  using do
    quote do
      alias ExCommerce.Checkout
      alias ExCommerce.Checkout.{Cart, CartServer, Order, OrderItemFixtures}
      alias ExCommerce.Marketplaces
      alias ExCommerce.Marketplaces.{Brand, Shop}

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
        ShopsFixtures
      }

      defp create_catalogue(_context) do
        %Catalogue{brand_id: brand_id} = catalogue = CataloguesFixtures.create()
        %Brand{} = brand = Marketplaces.get_brand!(brand_id)

        %{brand: brand, catalogue: catalogue}
      end

      defp create_shop(%{catalogue: %Catalogue{brand_id: brand_id}}),
        do: %{shop: ShopsFixtures.create(%{brand_id: brand_id})}

      defp relate_shop_catalogue(%{
             shop: %Shop{id: shop_id},
             catalogue: %Catalogue{id: catalogue_id}
           }) do
        {:ok, %Relations.ShopCatalogue{}} =
          Relations.create_shop_catalogue(%{
            shop_id: shop_id,
            catalogue_id: catalogue_id
          })

        # %Catalogue{} = _catalogue = Offerings.get_catalogue!(catalogue_id)

        %{}
      end

      defp create_catalogue_item_option_groups(%{brand: %Brand{id: brand_id}}),
        do: %{
          catalogue_item_option_group_1:
            CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})
        }

      defp create_catalogue_item_options(%{
             brand: %Brand{id: brand_id},
             catalogue_item_option_group_1: %CatalogueItemOptionGroup{
               id: catalogue_item_option_group_id
             }
           }),
           do: %{
             catalogue_item_option_1:
               CatalogueItemOptionsFixtures.create(%{
                 brand_id: brand_id,
                 catalogue_item_option_group_id: catalogue_item_option_group_id
               })
           }

      defp create_catalogue_items(%{brand: %Brand{id: brand_id}}),
        do: %{
          catalogue_item_1: CatalogueItemsFixtures.create(%{brand_id: brand_id})
        }

      defp relate_catalogue_item_option_groups_items(%{
             catalogue_item_option_group_1: %CatalogueItemOptionGroup{
               id: catalogue_item_option_group_id
             },
             catalogue_item_1: %CatalogueItem{id: catalogue_item_id}
           }) do
        %Relations.CatalogueItemOptionGroupItem{} =
          Offerings.RelationsFixtures.catalogue_item_option_group_item_fixture(
            %{
              catalogue_item_option_group_id: catalogue_item_option_group_id,
              catalogue_item_id: catalogue_item_id
            }
          )

        %{}
      end

      defp create_catalogue_item_variants(%{
             catalogue_item_1: %CatalogueItem{id: catalogue_item_id}
           }) do
        %{
          catalogue_item_variant_1:
            CatalogueItemVariantsFixtures.create(%{
              catalogue_item_id: catalogue_item_id
            })
        }
      end

      defp create_cart(%{catalogue: %Catalogue{id: catalogue_id}}) do
        cart_id = Cart.generate_id("some session id", catalogue_id)
        %Cart{} = cart = Cart.new(cart_id)

        %{cart: cart}
      end

      defp create_order(%{
             catalogue_item_1: %CatalogueItem{id: catalogue_item_1_id},
             catalogue_item_variant_1:
               %CatalogueItemVariant{id: variant_1_id} = variant_1,
             catalogue_item_option_1: %CatalogueItemOption{
               id: catalogue_item_option_1_id
             },
             catalogue_item_option_group_1:
               %CatalogueItemOptionGroup{id: catalogue_item_option_group_1_id} =
                 catalogue_item_option_group_1
           }) do
        catalogue_item_option_group_1 =
          ExCommerce.Repo.preload(
            catalogue_item_option_group_1,
            options: [:catalogue_item_variant]
          )

        %Ecto.Changeset{} =
          order_item =
          Cart.OrderItem.changeset(
            %Cart.OrderItem{
              variants: [variant_1],
              available_option_groups: %{
                values: [catalogue_item_option_group_1],
                rules: []
              }
            },
            %{
              catalogue_item_id: catalogue_item_1_id,
              option_groups: %{
                catalogue_item_option_group_1_id => %{
                  "valid?" => true,
                  "value" => [catalogue_item_option_1_id]
                }
              },
              quantity: 2,
              variant_id: variant_1_id
            }
          )

        %{order_item: order_item}
      end

      defp create_order_changeset(%{
             brand: %Brand{id: brand_id},
             cart: %Cart{} = cart,
             catalogue: %Catalogue{id: catalogue_id},
             shop: %Shop{id: shop_id}
           }) do
        %Cart.Order{} = order = Cart.get_order(cart)

        %Ecto.Changeset{} =
          cart_order_changeset =
          Cart.Order.changeset(order, %{
            brand_id: brand_id,
            catalogue_id: catalogue_id,
            shop_id: shop_id
          })

        %{cart_order_changeset: cart_order_changeset}
      end

      @spec order_item_attrs(map()) :: map()
      defp order_item_attrs(attrs \\ %{}) do
        order_item =
          OrderItemFixtures.build(attrs)
          |> Map.from_struct()
      end
    end
  end
end
