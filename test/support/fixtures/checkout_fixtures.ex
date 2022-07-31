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
  Generate an order_item.
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

  @valid_order_attrs %{
    buyer_name: "some buyer name",
    address: "some address",
    note: "some note"
  }
  @update_order_attrs %{
    buyer_name: "some updated buyer name",
    address: "some updated address",
    note: "some updated note"
  }
  @invalid_order_attrs %{
    buyer_name: nil,
    address: nil,
    note: nil
  }

  def valid_order_attrs(attrs \\ %{}),
    do: attrs |> Enum.into(@valid_order_attrs)

  def update_order_attrs(attrs \\ %{}),
    do: attrs |> Enum.into(@update_order_attrs)

  def invalid_order_attrs(attrs \\ %{}),
    do: attrs |> Enum.into(@invalid_order_attrs)

  @doc """
  Generate an order.
  """
  def order_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> maybe_assign_brand()
      |> maybe_assign_shop()
      |> maybe_assign_catalogue()

    {:ok, %Order{} = order} =
      attrs
      |> Enum.into(valid_order_attrs(attrs))
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
