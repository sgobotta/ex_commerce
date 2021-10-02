defmodule ExCommerce.BrandsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Marketplaces.Brand` context.
  """

  def unique_brand_name, do: "brand#{System.unique_integer()}"

  def valid_brand_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: unique_brand_name()
    })
  end

  def create(attrs \\ %{}) do
    {:ok, brand} =
      attrs
      |> valid_brand_attributes()
      |> ExCommerce.Marketplaces.create_brand()

    brand
  end
end
