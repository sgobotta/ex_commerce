defmodule ExCommerce.Offerings.RelationsTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.{
    BrandsFixtures,
    CatalogueCategoriesFixtures,
    CatalogueItemsFixtures,
    CataloguesFixtures
  }

  alias ExCommerce.Marketplaces.Brand

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueItem,
    Relations
  }

  import ExCommerce.Offerings.RelationsFixtures

  describe "catalogue_categories_items" do
    alias ExCommerce.Offerings.Relations.CatalogueCategoryItem

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
      %Offerings.CatalogueCategory{id: category_id} =
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

  describe "catalogues_categories" do
    alias ExCommerce.Offerings.Relations.CatalogueCategory

    @invalid_attrs %{visible: nil}

    setup do
      %{brand: BrandsFixtures.create()}
    end

    test "list_catalogues_categories/0 returns all catalogues_categories" do
      catalogue_category = catalogue_category_fixture()
      assert Relations.list_catalogues_categories() == [catalogue_category]
    end

    test "get_catalogue_category!/1 returns the catalogue_category with given id" do
      catalogue_category = catalogue_category_fixture()

      assert Relations.get_catalogue_category!(catalogue_category.id) ==
               catalogue_category
    end

    test "create_catalogue_category/1 with valid data creates a catalogue_category",
         %{brand: %Brand{id: brand_id}} do
      %Catalogue{id: catalogue_id} =
        CataloguesFixtures.create(%{brand_id: brand_id})

      %Offerings.CatalogueCategory{id: catalogue_category_id} =
        CatalogueCategoriesFixtures.create(%{brand_id: brand_id})

      valid_attrs =
        Map.merge(@valid_attrs, %{
          catalogue_id: catalogue_id,
          catalogue_category_id: catalogue_category_id
        })

      assert {:ok, %CatalogueCategory{} = catalogue_category} =
               Relations.create_catalogue_category(valid_attrs)

      assert catalogue_category.visible == true
    end

    test "create_catalogue_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Relations.create_catalogue_category(@invalid_attrs)
    end

    test "update_catalogue_category/2 with valid data updates the catalogue_category" do
      catalogue_category = catalogue_category_fixture()
      update_attrs = %{visible: false}

      assert {:ok, %CatalogueCategory{} = catalogue_category} =
               Relations.update_catalogue_category(
                 catalogue_category,
                 update_attrs
               )

      assert catalogue_category.visible == false
    end

    test "update_catalogue_category/2 with invalid data returns error changeset" do
      catalogue_category = catalogue_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Relations.update_catalogue_category(
                 catalogue_category,
                 @invalid_attrs
               )

      assert catalogue_category ==
               Relations.get_catalogue_category!(catalogue_category.id)
    end

    test "delete_catalogue_category/1 deletes the catalogue_category" do
      catalogue_category = catalogue_category_fixture()

      assert {:ok, %CatalogueCategory{}} =
               Relations.delete_catalogue_category(catalogue_category)

      assert_raise Ecto.NoResultsError, fn ->
        Relations.get_catalogue_category!(catalogue_category.id)
      end
    end

    test "change_catalogue_category/1 returns a catalogue_category changeset" do
      catalogue_category = catalogue_category_fixture()

      assert %Ecto.Changeset{} =
               Relations.change_catalogue_category(catalogue_category)
    end
  end
end
