defmodule ExCommerce.CheckoutFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Checkout` context.
  """

  @doc """
  Generate a order_item.
  """
  def order_item_fixture(attrs \\ %{}) do
    {:ok, order_item} =
      attrs
      |> Enum.into(%{
        catalogue_item_id: "some catalogue_item_id",
        variant_id: "some variant_id",
        quantity: 1
      })
      |> ExCommerce.Checkout.create_order_item()

    order_item
  end
end
