defmodule ExCommerce.Checkout.OrderFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `#{ExCommerce.Checkout}` context.
  """

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.Order

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    brand_name: "some brand name",
    shop_name: "some shop name",
    catalogue_name: "some catalogue name",
    buyer_name: "some buyer_name",
    address: "some address",
    note: "some note",
    price: ExCommerceNumeric.format_price(42.0),
    status: :pending
  }

  @update_attrs %{}

  @invalid_attrs %{
    brand_name: nil,
    shop_name: nil,
    catalogue_name: nil,
    buyer_name: nil,
    address: nil,
    note: nil,
    price: nil,
    status: nil
  }

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    attrs =
      attrs
      |> maybe_assign_brand()
      |> maybe_assign_shop()
      |> maybe_assign_catalogue()

    {:ok, %Order{} = order} =
      attrs
      |> Enum.into(valid_attrs(attrs))
      |> Checkout.create_order()

    order
  end
end

defmodule ExCommerce.Checkout.OrderItemFixtures do
  @moduledoc false

  alias ExCommerce.Checkout.OrderItem

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    quantity: 1,
    price: ExCommerceNumeric.format_price(21.0),
    variant_code: "SOME VARIANT CODE",
    variant_name: "some variant name",
    catalogue_item_code: "SOME CATALOGUE ITEM CODE",
    catalogue_item_description: "some catalogue item description",
    catalogue_item_name: "some catalogue item name"
  }

  @invalid_attrs %{
    quantity: nil,
    price: nil,
    variant_code: nil,
    variant_name: nil,
    catalogue_item_code: nil,
    catalogue_item_description: nil,
    catalogue_item_name: nil
  }

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def build(attrs \\ %{}) do
    attrs =
      attrs
      |> maybe_assign_catalogue_item()
      |> maybe_assign_catalogue_item_variant(attr: :variant_id)

    Map.merge(
      %OrderItem{},
      Enum.into(attrs, valid_attrs(attrs))
    )
  end
end

defmodule ExCommerce.Checkout.OrderItemOptionGroupFixtures do
  @moduledoc false

  alias ExCommerce.Checkout.OrderItemOptionGroup

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    catalogue_item_option_group_name: "some catalogue item option group name"
  }
  @invalid_attrs %{
    catalogue_item_option_group_name: nil
  }

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def build(attrs \\ %{}) do
    attrs =
      attrs
      |> maybe_assign_catalogue_item_option_group()

    Map.merge(
      %OrderItemOptionGroup{},
      Enum.into(attrs, valid_attrs(attrs))
    )
  end
end

defmodule ExCommerce.Checkout.OrderItemOptionFixtures do
  @moduledoc false

  alias ExCommerce.Checkout.OrderItemOption

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    catalogue_item_name: "some catalogue item name",
    catalogue_item_variant_name: "some catalogue item variant name",
    price: ExCommerceNumeric.format_price(2.0)
  }

  @invalid_attrs %{
    catalogue_item_name: nil,
    catalogue_item_variant_name: nil,
    price: nil
  }

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def build(attrs \\ %{}) do
    attrs =
      attrs
      |> maybe_assign_catalogue_item()
      |> maybe_assign_catalogue_item_variant()

    Map.merge(
      %OrderItemOption{},
      Enum.into(attrs, valid_attrs(attrs))
    )
  end
end
