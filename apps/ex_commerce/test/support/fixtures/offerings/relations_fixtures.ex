defmodule ExCommerce.Offerings.RelationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Offerings.Relations` context.
  """

  alias ExCommerce.{
    CatalogueCategoriesFixtures,
    CatalogueItemsFixtures,
    CataloguesFixtures
  }

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueCategory,
    CatalogueItem,
    Relations
  }

  alias ExCommerce.Offerings.Relations.CatalogueCategoryItem

  @valid_attrs %{visible: true}
  @update_attrs %{visible: false}
  @invalid_attrs %{visible: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  @doc """
  Generate a catalogue_category_item.
  """
  def catalogue_category_item_fixture(attrs \\ %{}) do
    %CatalogueItem{id: item_id} = CatalogueItemsFixtures.create(attrs)

    %CatalogueCategory{id: category_id} =
      CatalogueCategoriesFixtures.create(attrs)

    {:ok, %CatalogueCategoryItem{} = catalogue_category_item} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Enum.into(%{
        catalogue_item_id: item_id,
        catalogue_category_id: category_id
      })
      |> Relations.create_catalogue_category_item()

    catalogue_category_item
  end

  @doc """
  Generate a catalogue_category.
  """
  def catalogue_category_fixture(attrs \\ %{}) do
    %Catalogue{id: catalogue_id} = CataloguesFixtures.create(attrs)

    %CatalogueCategory{id: category_id} =
      CatalogueCategoriesFixtures.create(attrs)

    {:ok, %Relations.CatalogueCategory{} = catalogue_category} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Enum.into(%{
        catalogue_id: catalogue_id,
        catalogue_category_id: category_id
      })
      |> Relations.create_catalogue_category()

    catalogue_category
  end
end
