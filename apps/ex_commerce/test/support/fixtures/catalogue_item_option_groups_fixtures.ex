defmodule ExCommerce.CatalogueItemOptionGroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.CatalogueItemOptionGroup` context.
  """

  alias ExCommerce.BrandsFixtures
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItemOptionGroup

  @valid_attrs %{
    mandatory: true,
    max_selection: 42,
    multiple_selection: true
  }
  @update_attrs %{
    mandatory: false,
    max_selection: 43,
    multiple_selection: false
  }
  @invalid_attrs %{mandatory: nil, max_selection: nil, multiple_selection: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    attrs = assign_brand_maybe(attrs)

    {:ok, %CatalogueItemOptionGroup{} = catalogue_item_option_group} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue_item_option_group()

    catalogue_item_option_group
  end

  defp assign_brand_maybe(attrs) do
    case Map.has_key?(attrs, :brand_id) do
      false ->
        %Brand{id: brand_id} = BrandsFixtures.create()
        Map.merge(attrs, %{brand_id: brand_id})

      true ->
        attrs
    end
  end
end
