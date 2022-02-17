defmodule ExCommerce.CatalogueItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.CatalogueItem` context.
  """

  alias ExCommerce.BrandsFixtures
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItem

  @valid_attrs %{
    code: "some code",
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{code: nil, description: nil, name: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    attrs = assign_brand_maybe(attrs)

    {:ok, %CatalogueItem{} = catalogue_item} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue_item()

    catalogue_item
  end

  def create_assoc(item_attrs \\ %{}, item_variants_attrs \\ []) do
    item_attrs = assign_brand_maybe(item_attrs)

    {:ok, %{:catalogue_item => catalogue_item}} =
      Offerings.create_assoc_catalogue_item(
        {%CatalogueItem{}, item_attrs},
        item_variants_attrs
      )

    catalogue_item
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
