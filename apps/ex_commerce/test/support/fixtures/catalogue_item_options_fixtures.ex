defmodule ExCommerce.CatalogueItemOptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating entities via the
  `ExCommerce.Offerings.CatalogueItemOption` context.
  """

  alias ExCommerce.{
    BrandFixtures,
    CatalogueItemOptionGroup,
    CatalogueItemsFixtures,
    CatalogueItemVariantsFixtures
  }

  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  @valid_attrs %{price_modifier: 44, is_visible: true}
  @update_attrs %{price_modifier: 45, is_visible: false}
  @invalid_attrs %{price_modifier: nil, is_visible: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  def create(attrs \\ %{}) do
    attrs =
      attrs
      |> assign_brand_maybe()
      |> assign_catalogue_item_maybe()
      |> assign_catalogue_item_variant_maybe()
      |> assign_catalogue_item_option_group_maybe()

    {:ok, %CatalogueItemOption{} = catalogue_item_option} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Offerings.create_catalogue_item_option()

    catalogue_item_option
  end

  defp assign_brand_maybe(attrs) do
    case Map.has_key?(attrs, :brand_id) do
      false ->
        %Brand{id: brand_id} = BrandFixtures.create()
        Map.merge(attrs, %{brand_id: brand_id})

      true ->
        attrs
    end
  end

  defp assign_catalogue_item_maybe(attrs) do
    case Map.has_key?(attrs, :catalogue_item_id) do
      false ->
        %CatalogueItem{id: catalogue_item_id} = CatalogueItemsFixtures.create()
        Map.merge(attrs, %{catalogue_item_id: catalogue_item_id})

      true ->
        attrs
    end
  end

  defp assign_catalogue_item_variant_maybe(attrs) do
    case Map.has_key?(attrs, :catalogue_item_variant_id) do
      false ->
        %CatalogueItemVariant{id: catalogue_item_variant_id} =
          CatalogueItemVariantsFixtures.create()

        Map.merge(attrs, %{catalogue_item_variant_id: catalogue_item_variant_id})

      true ->
        attrs
    end
  end

  defp assign_catalogue_item_option_group_maybe(attrs) do
    case Map.has_key?(attrs, :catalogue_item_option_group_id) do
      false ->
        %CatalogueItemOptionGroup{id: catalogue_item_option_group_id} =
          CatalogueItemOptionGroupsFixtures.create()

        Map.merge(attrs, %{
          catalogue_item_option_group_id: catalogue_item_option_group_id
        })

      true ->
        attrs
    end
  end

  # defp assign_dependency_maybe(attrs) do

  # end
end
