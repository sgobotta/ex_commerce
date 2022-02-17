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

  describe "catalogue_categories_items" do
    alias ExCommerce.Offerings.Relations.CatalogueCategoryItem

    import ExCommerce.Offerings.RelationsFixtures

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

    import ExCommerce.Offerings.RelationsFixtures

    @invalid_attrs %{visible: nil}

    test "list_catalogues_categories/0 returns all catalogues_categories" do
      catalogue_category = catalogue_category_fixture()
      assert Relations.list_catalogues_categories() == [catalogue_category]
    end

    test "get_catalogue_category!/1 returns the catalogue_category with given id" do
      catalogue_category = catalogue_category_fixture()

      assert Relations.get_catalogue_category!(catalogue_category.id) ==
               catalogue_category
    end

    test "create_catalogue_category/1 with valid data creates a catalogue_category" do
      %Brand{id: brand_id} = BrandsFixtures.create()

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

  describe "shops_catalogues" do
    alias ExCommerce.{
      CataloguesFixtures,
      ShopsFixtures
    }

    alias ExCommerce.Marketplaces
    alias ExCommerce.Offerings.Relations.ShopCatalogue

    alias ExCommerce.Offerings.Relations.ShopCatalogueFixtures

    @invalid_attrs %{visible: nil}

    setup do
      %{brand: BrandsFixtures.create()}
    end

    test "list_shops_catalogues/0 returns all shops_catalogues" do
      %ShopCatalogue{} = shop_catalogue = ShopCatalogueFixtures.create()
      assert Relations.list_shops_catalogues() == [shop_catalogue]
    end

    test "get_shop_catalogue!/1 returns the shop_catalogue with given id" do
      %ShopCatalogue{} = shop_catalogue = ShopCatalogueFixtures.create()
      assert Relations.get_shop_catalogue!(shop_catalogue.id) == shop_catalogue
    end

    test "create_shop_catalogue/1 with valid data creates a shop_catalogue", %{
      brand: %Brand{id: brand_id}
    } do
      %Marketplaces.Shop{id: shop_id} =
        ShopsFixtures.create(%{brand_id: brand_id})

      %Offerings.Catalogue{id: catalogue_id} =
        CataloguesFixtures.create(%{brand_id: brand_id})

      valid_attrs =
        Map.merge(@valid_attrs, %{
          catalogue_id: catalogue_id,
          shop_id: shop_id
        })

      assert {:ok, %ShopCatalogue{} = shop_catalogue} =
               Relations.create_shop_catalogue(valid_attrs)

      assert shop_catalogue.visible == true
    end

    test "create_shop_catalogue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Relations.create_shop_catalogue(@invalid_attrs)
    end

    test "update_shop_catalogue/2 with valid data updates the shop_catalogue" do
      %ShopCatalogue{} = shop_catalogue = ShopCatalogueFixtures.create()
      update_attrs = %{visible: false}

      assert {:ok, %ShopCatalogue{} = shop_catalogue} =
               Relations.update_shop_catalogue(shop_catalogue, update_attrs)

      assert shop_catalogue.visible == false
    end

    test "update_shop_catalogue/2 with invalid data returns error changeset" do
      %ShopCatalogue{} = shop_catalogue = ShopCatalogueFixtures.create()

      assert {:error, %Ecto.Changeset{}} =
               Relations.update_shop_catalogue(shop_catalogue, @invalid_attrs)

      assert shop_catalogue == Relations.get_shop_catalogue!(shop_catalogue.id)
    end

    test "delete_shop_catalogue/1 deletes the shop_catalogue" do
      %ShopCatalogue{} = shop_catalogue = ShopCatalogueFixtures.create()

      assert {:ok, %ShopCatalogue{}} =
               Relations.delete_shop_catalogue(shop_catalogue)

      assert_raise Ecto.NoResultsError, fn ->
        Relations.get_shop_catalogue!(shop_catalogue.id)
      end
    end

    test "change_shop_catalogue/1 returns a shop_catalogue changeset" do
      %ShopCatalogue{} = shop_catalogue = ShopCatalogueFixtures.create()
      assert %Ecto.Changeset{} = Relations.change_shop_catalogue(shop_catalogue)
    end
  end
end
