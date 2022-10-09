defmodule ExCommerce.CatalogueItemVariantsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.CatalogueItemVariant` context.
  """

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItemVariant

  import ExCommerce.FixtureHelpers

  @valid_attrs %{
    code: "some code",
    type: "some type",
    price: Decimal.new("120.5")
  }
  @update_attrs %{
    code: "some updated code",
    type: "some updated type",
    price: Decimal.new("456.7")
  }
  @invalid_attrs %{code: nil, type: nil, price: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    attrs = maybe_assign_catalogue_item(attrs)

    {:ok, %CatalogueItemVariant{} = catalogue_item_variant} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue_item_variant()

    catalogue_item_variant
  end
end
