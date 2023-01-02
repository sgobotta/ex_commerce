defmodule ExCommerce.CheckoutTest do
  @moduledoc false
  use ExCommerce.DataCase

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.Order
  alias ExCommerce.Marketplaces

  require Decimal

  describe "checkout" do
    alias ExCommerce.Checkout.{Cart, CartServer, Order}

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

    setup do
      %Catalogue{
        id: catalogue_id,
        brand_id: brand_id
      } = CataloguesFixtures.create()

      %Marketplaces.Brand{} = brand = Marketplaces.get_brand!(brand_id)

      %Marketplaces.Shop{id: shop_id} =
        shop =
        ShopsFixtures.create(%{
          brand_id: brand_id
        })

      # Relate Marketplaces.Shop with Offerings.Catalogue
      {:ok, %Relations.ShopCatalogue{}} =
        Relations.create_shop_catalogue(%{
          shop_id: shop_id,
          catalogue_id: catalogue_id
        })

      %Catalogue{
        id: catalogue_id
      } = catalogue = Offerings.get_catalogue!(catalogue_id)

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

      %Cart.Order{} = order = Cart.get_order(cart)

      %Ecto.Changeset{} =
        cart_order_changeset =
        Cart.Order.changeset(order, %{
          brand_id: brand_id,
          catalogue_id: catalogue_id,
          shop_id: shop_id
        })

      %{
        brand: brand,
        cart: cart,
        catalogue: catalogue,
        cart_order_changeset: cart_order_changeset,
        order_item: order_item,
        shop: shop
      }
    end

    test "update_cart_order/2 returns a #{Cart} with an updated #{Cart.Order}",
         %{
           cart: %Cart{} = cart,
           cart_order_changeset: %Ecto.Changeset{} = cart_order_changeset
         } do
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

    test "add_to_order/2 adds an #{Cart.OrderItem} to a new #{Cart.Order}", %{
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
        Enum.at(order_items, 0)

      assert quantity == 2
      assert Decimal.is_decimal(price)
    end

    @tag :wip
    test "from_cart_order/1 for a cart order with invalid args returns an invalid #{Order} changeset",
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
        Checkout.update_cart_order(cart, cart_order_changeset)

      from_cart_order_params = %{
        brand_name: brand_name,
        catalogue_name: catalogue_name,
        shop_name: shop_name
      }

      # Exercise
      {:error, %Ecto.Changeset{valid?: valid?, errors: _errors}} =
        Checkout.from_cart_order(cart_order, from_cart_order_params)

      # Verify
      refute valid?
    end
  end

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
        shop: ShopsFixtures.create(%{brand_id: brand_id})
      }
    end

    test "list_orders/0 returns all orders" do
      %Order{} = order = OrderFixtures.create()
      assert Checkout.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      %Order{id: order_id} = order = OrderFixtures.create()
      assert Checkout.get_order!(order_id) == order
    end

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

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checkout.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      %Order{} = order = OrderFixtures.create()

      assert {:ok, %Order{}} = Checkout.update_order(order, @update_attrs)
    end

    test "update_order/2 with invalid data returns error changeset" do
      %Order{id: order_id} = order = OrderFixtures.create()

      assert {:error, %Ecto.Changeset{}} =
               Checkout.update_order(order, @invalid_attrs)

      assert order == Checkout.get_order!(order_id)
    end

    test "delete_order/1 deletes the order" do
      %Order{id: order_id} = order = OrderFixtures.create()
      assert {:ok, %Order{}} = Checkout.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Checkout.get_order!(order_id) end
    end

    test "change_order/1 returns an order changeset" do
      %Order{} = order = OrderFixtures.create()
      assert %Ecto.Changeset{} = Checkout.change_order(order)
    end
  end
end
