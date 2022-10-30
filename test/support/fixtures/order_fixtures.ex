defmodule ExCommerce.OrderFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `#{ExCommerce.Checkout}` context.
  """

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.Order

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    buyer_name: "some buyer name",
    address: "some address",
    note: "some note"
  }
  @update_attrs %{
    buyer_name: "some updated buyer name",
    address: "some updated address",
    note: "some updated note"
  }
  @invalid_attrs %{
    buyer_name: nil,
    address: nil,
    note: nil
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
