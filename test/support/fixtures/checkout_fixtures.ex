defmodule ExCommerce.CheckoutFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Checkout` context.
  """

  alias ExCommerce.Checkout.{Order, OrderItem}

  alias ExCommerce.Offerings.CatalogueItemVariant

  alias ExCommerce.CatalogueItemVariantsFixtures

  import ExCommerce.FixtureHelpers

  @doc """
  Generate a order_item.
  """
  def order_item_fixture(attrs \\ %{}) do
    {:ok, %OrderItem{} = order_item} =
      attrs
      |> maybe_assign_catalogue_item()
      |> maybe_assign_variant()
      |> Enum.into(%{
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
      |> maybe_assign_brand()
      |> maybe_assign_shop()
      |> maybe_assign_catalogue()

    {:ok, %Order{} = order} =
      attrs
      |> Enum.into(%{})
      |> ExCommerce.Checkout.create_order()

    order
  end

  defp maybe_assign_variant(attrs),
    do:
      maybe_assign(
        attrs,
        :variant_id,
        CatalogueItemVariant,
        CatalogueItemVariantsFixtures
      )
end
