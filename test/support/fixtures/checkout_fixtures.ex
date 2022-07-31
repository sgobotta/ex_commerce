defmodule ExCommerce.CheckoutFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Checkout` context.
  """

  alias ExCommerce.{BrandsFixtures, CataloguesFixtures, ShopsFixtures}
  alias ExCommerce.Checkout.{Order, OrderItem}
  alias ExCommerce.Marketplaces.{Brand, Shop}
  alias ExCommerce.Offerings.Catalogue

  import ExCommerce.FixtureHelpers

  @doc """
  Generate a order_item.
  """
  def order_item_fixture(attrs \\ %{}) do
    {:ok, %OrderItem{} = order_item} =
      attrs
      |> Enum.into(%{
        catalogue_item_id: "some catalogue_item_id",
        variant_id: "some variant_id",
        price: ExCommerceNumeric.format_price(42.0),
        quantity: 1
      })
      |> ExCommerce.Checkout.create_order_item()

    order_item
  end

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> assign_brand_maybe()
      |> assign_shop_maybe()
      |> assign_catalogue_maybe()

    {:ok, %Order{} = order} =
      attrs
      |> Enum.into(%{
        brand_id: Ecto.UUID.generate(),
        shop_id: Ecto.UUID.generate(),
        catalogue_id: Ecto.UUID.generate()
      })
      |> ExCommerce.Checkout.create_order()

    order
  end

  defp assign_brand_maybe(attrs),
    do: maybe_assign(attrs, :brand_id, Brand, BrandsFixtures)

  defp assign_shop_maybe(attrs),
    do: maybe_assign(attrs, :shop_id, Shop, ShopsFixtures)

  defp assign_catalogue_maybe(attrs),
    do: maybe_assign(attrs, :catalogue_id, Catalogue, CataloguesFixtures)
end
