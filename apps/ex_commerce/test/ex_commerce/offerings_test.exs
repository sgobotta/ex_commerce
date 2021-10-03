defmodule ExCommerce.OfferingsTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.Offerings

  describe "catalogues" do
    alias ExCommerce.BrandsFixtures
    alias ExCommerce.Marketplaces.Brand
    alias ExCommerce.Offerings.Catalogue

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    setup do
      %{brand: BrandsFixtures.create()}
    end

    def catalogue_fixture(attrs \\ %{}) do
      {:ok, %Catalogue{} = catalogue} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Offerings.create_catalogue()

      catalogue
    end

    test "list_catalogues/0 returns all catalogues", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{} = catalogue = catalogue_fixture(%{brand_id: brand_id})
      assert Offerings.list_catalogues() == [catalogue]
    end

    test "list_catalogues_by_brand/1 returns all catalogues for a given brand",
         %{
           brand: %Brand{id: brand_id}
         } do
      %Catalogue{} = catalogue = catalogue_fixture(%{brand_id: brand_id})
      assert Offerings.list_catalogues_by_brand(brand_id) == [catalogue]
    end

    test "get_catalogue!/1 returns the catalogue with given id", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{id: catalogue_id} =
        catalogue = catalogue_fixture(%{brand_id: brand_id})

      assert Offerings.get_catalogue!(catalogue_id) == catalogue
    end

    test "create_catalogue/1 with valid data creates a catalogue", %{
      brand: %Brand{id: brand_id}
    } do
      valid_attrs = Map.merge(@valid_attrs, %{brand_id: brand_id})

      assert {:ok, %Catalogue{} = catalogue} =
               Offerings.create_catalogue(valid_attrs)

      assert catalogue.name == valid_attrs.name
    end

    test "create_catalogue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Offerings.create_catalogue(@invalid_attrs)
    end

    test "update_catalogue/2 with valid data updates the catalogue", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{} = catalogue = catalogue_fixture(%{brand_id: brand_id})

      assert {:ok, %Catalogue{} = catalogue} =
               Offerings.update_catalogue(catalogue, @update_attrs)

      assert catalogue.name == @update_attrs.name
    end

    test "update_catalogue/2 with invalid data returns error changeset", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{id: catalogue_id} =
        catalogue = catalogue_fixture(%{brand_id: brand_id})

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue(catalogue, @invalid_attrs)

      assert catalogue == Offerings.get_catalogue!(catalogue_id)
    end

    test "delete_catalogue/1 deletes the catalogue", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{id: catalogue_id} =
        catalogue = catalogue_fixture(%{brand_id: brand_id})

      assert {:ok, %Catalogue{}} = Offerings.delete_catalogue(catalogue)

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue!(catalogue_id)
      end
    end

    test "change_catalogue/1 returns a catalogue changeset", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{} = catalogue = catalogue_fixture(%{brand_id: brand_id})
      assert %Ecto.Changeset{} = Offerings.change_catalogue(catalogue)
    end
  end

  describe "catalogue_categories" do
    alias ExCommerce.BrandsFixtures
    alias ExCommerce.Marketplaces.Brand
    alias ExCommerce.Offerings.CatalogueCategory

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

    setup do
      %{brand: BrandsFixtures.create()}
    end

    def catalogue_category_fixture(attrs \\ %{}) do
      {:ok, %CatalogueCategory{} = catalogue_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Offerings.create_catalogue_category()

      catalogue_category
    end

    test "list_catalogue_categories/0 returns all catalogue_categories", %{
      brand: %Brand{id: brand_id}
    } do
      %CatalogueCategory{} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert Offerings.list_catalogue_categories() == [catalogue_category]
    end

    test "list_catalogue_categories_by_brand/1 returns all catalogue_categories for a given brand",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueCategory{} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert Offerings.list_catalogue_categories_by_brand(brand_id) == [
               catalogue_category
             ]
    end

    test "get_catalogue_category!/1 returns the catalogue_category with given id",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueCategory{id: catalogue_category_id} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert Offerings.get_catalogue_category!(catalogue_category_id) ==
               catalogue_category
    end

    test "create_catalogue_category/1 with valid data creates a catalogue_category",
         %{
           brand: %Brand{id: brand_id}
         } do
      valid_attrs = Map.merge(@valid_attrs, %{brand_id: brand_id})

      assert {:ok, %CatalogueCategory{} = catalogue_category} =
               Offerings.create_catalogue_category(valid_attrs)

      assert catalogue_category.code == @valid_attrs.code
      assert catalogue_category.description == @valid_attrs.description
      assert catalogue_category.name == @valid_attrs.name
    end

    test "create_catalogue_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Offerings.create_catalogue_category(@invalid_attrs)
    end

    test "update_catalogue_category/2 with valid data updates the catalogue_category",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueCategory{} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert {:ok, %CatalogueCategory{} = catalogue_category} =
               Offerings.update_catalogue_category(
                 catalogue_category,
                 @update_attrs
               )

      assert catalogue_category.code == @update_attrs.code
      assert catalogue_category.description == @update_attrs.description
      assert catalogue_category.name == @update_attrs.name
    end

    test "update_catalogue_category/2 with invalid data returns error changeset",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueCategory{id: catalogue_category_id} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue_category(
                 catalogue_category,
                 @invalid_attrs
               )

      assert catalogue_category ==
               Offerings.get_catalogue_category!(catalogue_category_id)
    end

    test "delete_catalogue_category/1 deletes the catalogue_category", %{
      brand: %Brand{id: brand_id}
    } do
      %CatalogueCategory{id: catalogue_category_id} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert {:ok, %CatalogueCategory{}} =
               Offerings.delete_catalogue_category(catalogue_category)

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue_category!(catalogue_category_id)
      end
    end

    test "change_catalogue_category/1 returns a catalogue_category changeset",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueCategory{} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert %Ecto.Changeset{} =
               Offerings.change_catalogue_category(catalogue_category)
    end
  end

  describe "catalogue_items" do
    alias ExCommerce.BrandsFixtures
    alias ExCommerce.Marketplaces.Brand
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

    setup do
      %{brand: BrandsFixtures.create()}
    end

    def catalogue_item_fixture(attrs \\ %{}) do
      {:ok, %CatalogueItem{} = catalogue_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Offerings.create_catalogue_item()

      catalogue_item
    end

    test "list_catalogue_items/0 returns all catalogue_items", %{
      brand: %Brand{id: brand_id}
    } do
      catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})
      assert Offerings.list_catalogue_items() == [catalogue_item]
    end

    test "list_catalogue_items_by_brand/1 returns all catalogue_items for a given brand",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItem{} =
        catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})

      assert Offerings.list_catalogue_items_by_brand(brand_id) == [
               catalogue_item
             ]
    end

    test "get_catalogue_item!/1 returns the catalogue_item with given id", %{
      brand: %Brand{id: brand_id}
    } do
      %CatalogueItem{id: catalogue_item_id} =
        catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})

      assert Offerings.get_catalogue_item!(catalogue_item_id) == catalogue_item
    end

    test "create_catalogue_item/1 with valid data creates a catalogue_item", %{
      brand: %Brand{id: brand_id}
    } do
      valid_attrs = Map.merge(@valid_attrs, %{brand_id: brand_id})

      assert {:ok, %CatalogueItem{} = catalogue_item} =
               Offerings.create_catalogue_item(valid_attrs)

      assert catalogue_item.code == @valid_attrs.code
      assert catalogue_item.description == @valid_attrs.description
      assert catalogue_item.name == @valid_attrs.name
    end

    test "create_catalogue_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Offerings.create_catalogue_item(@invalid_attrs)
    end

    test "update_catalogue_item/2 with valid data updates the catalogue_item",
         %{brand: %Brand{id: brand_id}} do
      catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})

      assert {:ok, %CatalogueItem{} = catalogue_item} =
               Offerings.update_catalogue_item(catalogue_item, @update_attrs)

      assert catalogue_item.code == @update_attrs.code
      assert catalogue_item.description == @update_attrs.description
      assert catalogue_item.name == @update_attrs.name
    end

    test "update_catalogue_item/2 with invalid data returns error changeset", %{
      brand: %Brand{id: brand_id}
    } do
      %CatalogueItem{id: catalogue_item_id} =
        catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue_item(catalogue_item, @invalid_attrs)

      assert catalogue_item == Offerings.get_catalogue_item!(catalogue_item_id)
    end

    test "delete_catalogue_item/1 deletes the catalogue_item", %{
      brand: %Brand{id: brand_id}
    } do
      %CatalogueItem{id: catalogue_item_id} =
        catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})

      assert {:ok, %CatalogueItem{}} =
               Offerings.delete_catalogue_item(catalogue_item)

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue_item!(catalogue_item_id)
      end
    end

    test "change_catalogue_item/1 returns a catalogue_item changeset", %{
      brand: %Brand{id: brand_id}
    } do
      catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})
      assert %Ecto.Changeset{} = Offerings.change_catalogue_item(catalogue_item)
    end
  end
end
