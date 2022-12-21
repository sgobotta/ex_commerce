defmodule ExCommerce.OrderItemFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `#{ExCommerce.Checkout}` context.
  """

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.OrderItem

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    quantity: 1,
    price: ExCommerceNumeric.format_price(42.0)
  }
  @update_attrs %{
    quantity: 2,
    price: ExCommerceNumeric.format_price(84.0)
  }
  @invalid_attrs %{
    quantity: nil,
    price: nil
  }

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    attrs =
      attrs
      |> maybe_assign_catalogue_item()
      |> maybe_assign_catalogue_item_variant(attr: :variant_id)
      |> maybe_assign_order()

    {:ok, %OrderItem{} = order_item} =
      attrs
      |> Enum.into(valid_attrs(attrs))
      |> Checkout.create_order_item()

    order_item
  end

  def build(attrs \\ %{}) do
    attrs =
      attrs
      |> maybe_assign_catalogue_item()
      |> maybe_assign_catalogue_item_variant(attr: :variant_id)
      |> maybe_assign_order(:build)
      |> Enum.into(valid_attrs(attrs))

    %OrderItem{} = Map.merge(%OrderItem{}, attrs)
  end
end
