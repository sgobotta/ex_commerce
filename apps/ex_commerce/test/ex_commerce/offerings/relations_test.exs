defmodule ExCommerce.Offerings.RelationsTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.{
    BrandsFixtures,
    CatalogueCategoriesFixtures,
    CatalogueItemsFixtures
  }

  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings.Relations

  import ExCommerce.Offerings.RelationsFixtures

  describe "catalogue_categories_items" do
    alias ExCommerce.Offerings.Relations.CatalogueCategoryItem

    alias ExCommerce.Offerings.{
      CatalogueCategory,
      CatalogueItem
    }

    @valid_attrs valid_attrs()
    @update_attrs update_attrs()
    @invalid_attrs invalid_attrs()

    setup do
      %{brand: BrandsFixtures.create()}
    end

    test "list_catalogue_categories_items/0 returns all catalogue_categories_items",
         %{brand: %Brand{id: brand_id}} do
      %CatalogueCategoryItem{} =
        catalogue_category_item =
        catalogue_category_item_fixture(%{brand_id: brand_id})

      assert Relations.list_catalogue_categories_items() == [
               catalogue_category_item
             ]
    end

    test "get_catalogue_category_item!/1 returns the catalogue_category_item with given id",
         %{brand: %Brand{id: brand_id}} do
      %CatalogueCategoryItem{} =
        catalogue_category_item =
        catalogue_category_item_fixture(%{brand_id: brand_id})

      assert Relations.get_catalogue_category_item!(catalogue_category_item.id) ==
               catalogue_category_item
    end

    test "create_catalogue_category_item/1 with valid data creates a catalogue_category_item",
         %{brand: %Brand{id: brand_id}} do
      %CatalogueCategory{id: category_id} =
        CatalogueCategoriesFixtures.create(%{brand_id: brand_id})

      %CatalogueItem{id: item_id} =
        CatalogueItemsFixtures.create(%{brand_id: brand_id})

      valid_attrs =
        Map.merge(@valid_attrs, %{
          catalogue_item_id: item_id,
          catalogue_category_id: category_id
        })

      assert {:ok, %CatalogueCategoryItem{} = catalogue_category_item} =
               Relations.create_catalogue_category_item(valid_attrs)

      assert catalogue_category_item.visible == true
    end

    test "create_catalogue_category_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Relations.create_catalogue_category_item(@invalid_attrs)
    end

    test "update_catalogue_category_item/2 with valid data updates the catalogue_category_item",
         %{brand: %Brand{id: brand_id}} do
      %CatalogueCategoryItem{} =
        catalogue_category_item =
        catalogue_category_item_fixture(%{brand_id: brand_id})

      assert {:ok, %CatalogueCategoryItem{} = catalogue_category_item} =
               Relations.update_catalogue_category_item(
                 catalogue_category_item,
                 @update_attrs
               )

      assert catalogue_category_item.visible == false
    end

    test "update_catalogue_category_item/2 with invalid data returns error changeset",
         %{brand: %Brand{id: brand_id}} do
      %CatalogueCategoryItem{} =
        catalogue_category_item =
        catalogue_category_item_fixture(%{brand_id: brand_id})

      assert {:error, %Ecto.Changeset{}} =
               Relations.update_catalogue_category_item(
                 catalogue_category_item,
                 @invalid_attrs
               )

      assert catalogue_category_item ==
               Relations.get_catalogue_category_item!(
                 catalogue_category_item.id
               )
    end

    test "delete_catalogue_category_item/1 deletes the catalogue_category_item",
         %{brand: %Brand{id: brand_id}} do
      %CatalogueCategoryItem{} =
        catalogue_category_item =
        catalogue_category_item_fixture(%{brand_id: brand_id})

      assert {:ok, %CatalogueCategoryItem{}} =
               Relations.delete_catalogue_category_item(catalogue_category_item)

      assert_raise Ecto.NoResultsError, fn ->
        Relations.get_catalogue_category_item!(catalogue_category_item.id)
      end
    end

    test "change_catalogue_category_item/1 returns a catalogue_category_item changeset",
         %{brand: %Brand{id: brand_id}} do
      %CatalogueCategoryItem{} =
        catalogue_category_item =
        catalogue_category_item_fixture(%{brand_id: brand_id})

      assert %Ecto.Changeset{} =
               Relations.change_catalogue_category_item(catalogue_category_item)
    end
  end
end
