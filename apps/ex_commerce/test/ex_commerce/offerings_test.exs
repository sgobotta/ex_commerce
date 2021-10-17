defmodule ExCommerce.OfferingsTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.Offerings
  alias ExCommerce.Repo

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
    alias ExCommerce.{
      BrandsFixtures,
      CatalogueItemsFixtures,
      CatalogueItemVariantsFixtures
    }

    alias ExCommerce.Marketplaces.Brand
    alias ExCommerce.Offerings.{CatalogueItem, CatalogueItemVariant}

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

    test "create_assoc_catalogue_item/2 with valid data updates a catalogue item with catalogue item variants",
         %{brand: %Brand{id: brand_id}} do
      valid_catalogue_item_attrs =
        Map.merge(@valid_attrs, %{brand_id: brand_id})

      valid_catalogue_variants_attrs =
        for _n <- 1..3 do
          {%CatalogueItemVariant{}, CatalogueItemVariantsFixtures.valid_attrs()}
        end

      %CatalogueItem{} =
        catalogue_item =
        CatalogueItemsFixtures.create_assoc(
          valid_catalogue_item_attrs,
          valid_catalogue_variants_attrs
        )

      %{variants: preloaded_variants} =
        Repo.preload(catalogue_item, [:variants])

      assert length(preloaded_variants) ==
               length(valid_catalogue_variants_attrs)
    end

    test "create_assoc_catalogue_item/2 with valid data creates and updates a catalogue item with catalogue item variants",
         %{brand: %Brand{id: brand_id}} do
      %{
        brand_id: catalogue_item_brand_id,
        code: catalogue_item_code,
        description: catalogue_item_description,
        name: catalogue_item_name
      } =
        valid_catalogue_item_attrs =
        Map.merge(@valid_attrs, %{brand_id: brand_id})

      some_item_variant =
        %{
          type: some_item_variant_type,
          price: some_item_variant_price
        } = CatalogueItemVariantsFixtures.valid_attrs()

      some_item_variant_ecto_multi_key = {:catalogue_item_variant, 0}

      some_other_item_variant =
        %{
          type: some_other_item_variant_type,
          price: some_other_item_variant_price
        } = CatalogueItemVariantsFixtures.valid_attrs()

      some_other_item_variant_ecto_multi_key = {:catalogue_item_variant, 1}

      valid_catalogue_item_variants_attrs = [
        {%CatalogueItemVariant{}, some_item_variant},
        {%CatalogueItemVariant{}, some_other_item_variant}
      ]

      assert {:ok, result} =
               Offerings.create_assoc_catalogue_item(
                 {%CatalogueItem{}, valid_catalogue_item_attrs},
                 valid_catalogue_item_variants_attrs
               )

      assert %{
               :catalogue_item =>
                 %CatalogueItem{
                   id: catalogue_item_id,
                   brand_id: ^catalogue_item_brand_id,
                   code: ^catalogue_item_code,
                   description: ^catalogue_item_description,
                   name: ^catalogue_item_name
                 } = catalogue_item,
               ^some_item_variant_ecto_multi_key =>
                 %CatalogueItemVariant{
                   id: some_item_variant_id,
                   type: ^some_item_variant_type,
                   price: ^some_item_variant_price
                 } = some_item_variant,
               ^some_other_item_variant_ecto_multi_key =>
                 %CatalogueItemVariant{
                   id: some_other_item_variant_id,
                   type: ^some_other_item_variant_type,
                   price: ^some_other_item_variant_price
                 } = some_other_item_variant
             } = result

      # Check catalogue_item and catalogue_item_variants were correctly saved.
      assert Offerings.get_catalogue_item!(catalogue_item_id) == catalogue_item

      assert Offerings.get_catalogue_item_variant!(some_item_variant_id) ==
               some_item_variant

      assert(
        Offerings.get_catalogue_item_variant!(some_other_item_variant_id) ==
          some_other_item_variant
      )

      # Check new variants are correctly preloaded in %CatalogueItem{} structs
      catalogue_item_variants = [some_item_variant, some_other_item_variant]

      %{variants: preloaded_variants} =
        Repo.preload(catalogue_item, [:variants])

      for catalogue_item_variant <- preloaded_variants do
        assert Enum.member?(catalogue_item_variants, catalogue_item_variant)
      end

      # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
      # Updates existent catalogue item and variants

      %{
        code: update_catalogue_item_code,
        description: update_catalogue_item_description,
        name: update_catalogue_item_name
      } = @update_attrs

      some_updated_item_variant =
        %{
          type: some_updated_item_variant_type,
          price: some_updated_item_variant_price
        } = CatalogueItemVariantsFixtures.update_attrs()

      some_other_updated_item_variant =
        %{
          type: some_other_updated_item_variant_type,
          price: some_other_updated_item_variant_price
        } = CatalogueItemVariantsFixtures.update_attrs()

      update_catalogue_item_variants_attrs = [
        {some_item_variant, some_updated_item_variant},
        {some_other_item_variant, some_other_updated_item_variant}
      ]

      assert {:ok, result} =
               Offerings.create_assoc_catalogue_item(
                 {catalogue_item, @update_attrs},
                 update_catalogue_item_variants_attrs
               )

      assert %{
               :catalogue_item =>
                 %CatalogueItem{
                   id: ^catalogue_item_id,
                   brand_id: ^catalogue_item_brand_id,
                   code: ^update_catalogue_item_code,
                   description: ^update_catalogue_item_description,
                   name: ^update_catalogue_item_name
                 } = updated_catalogue_item,
               ^some_item_variant_ecto_multi_key =>
                 %CatalogueItemVariant{
                   id: ^some_item_variant_id,
                   type: ^some_updated_item_variant_type,
                   price: ^some_updated_item_variant_price
                 } = some_updated_item_variant,
               ^some_other_item_variant_ecto_multi_key =>
                 %CatalogueItemVariant{
                   id: ^some_other_item_variant_id,
                   type: ^some_other_updated_item_variant_type,
                   price: ^some_other_updated_item_variant_price
                 } = some_other_updated_item_variant
             } = result

      # Check catalogue_item and catalogue_item_variants were correctly updated.
      assert Offerings.get_catalogue_item!(catalogue_item_id) ==
               updated_catalogue_item

      assert Offerings.get_catalogue_item_variant!(some_item_variant_id) ==
               some_updated_item_variant

      assert(
        Offerings.get_catalogue_item_variant!(some_other_item_variant_id) ==
          some_other_updated_item_variant
      )

      # Check new variants are correctly preloaded in %CatalogueItem{} structs
      updated_catalogue_item_variants = [
        some_updated_item_variant,
        some_other_updated_item_variant
      ]

      %{variants: preloaded_variants} =
        Repo.preload(catalogue_item, [:variants])

      for catalogue_item_variant <- preloaded_variants do
        assert Enum.member?(
                 updated_catalogue_item_variants,
                 catalogue_item_variant
               )
      end

      # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
      # Calls create_assoc_catalogue_item without changes

      update_catalogue_item_variants_attrs = [
        {some_updated_item_variant, %{}},
        {some_other_updated_item_variant, %{}}
      ]

      assert {:ok, result} =
               Offerings.create_assoc_catalogue_item(
                 {updated_catalogue_item, %{}},
                 update_catalogue_item_variants_attrs
               )

      assert %{
               :catalogue_item => %CatalogueItem{} = ^updated_catalogue_item,
               ^some_item_variant_ecto_multi_key =>
                 %CatalogueItemVariant{} = ^some_updated_item_variant,
               ^some_other_item_variant_ecto_multi_key =>
                 %CatalogueItemVariant{} = ^some_other_updated_item_variant
             } = result
    end

    test "create_assoc_catalogue_item/2 fails on invalid catalogue_item attributes",
         %{brand: %Brand{id: brand_id}} do
      invalid_catalogue_item_attrs =
        Map.merge(@invalid_attrs, %{brand_id: brand_id})

      some_item_variant =
        CatalogueItemVariantsFixtures.valid_attrs(%{id: Ecto.UUID.generate()})

      some_other_item_variant =
        CatalogueItemVariantsFixtures.valid_attrs(%{id: Ecto.UUID.generate()})

      valid_catalogue_item_variants_attrs = [
        {%CatalogueItemVariant{}, some_item_variant},
        {%CatalogueItemVariant{}, some_other_item_variant}
      ]

      assert {:error, :catalogue_item, changeset, %{}} =
               Offerings.create_assoc_catalogue_item(
                 {%CatalogueItem{}, invalid_catalogue_item_attrs},
                 valid_catalogue_item_variants_attrs
               )

      refute changeset.valid?

      assert {"can't be blank", [validation: :required]} =
               Keyword.get(changeset.errors, :code)

      assert {"can't be blank", [validation: :required]} =
               Keyword.get(changeset.errors, :name)

      assert {"can't be blank", [validation: :required]} =
               Keyword.get(changeset.errors, :description)
    end

    test "create_assoc_catalogue_item/2 fails on invalid catalogue_item_variant attributes",
         %{brand: %Brand{id: brand_id}} do
      %{
        brand_id: catalogue_item_brand_id,
        code: catalogue_item_code,
        description: catalogue_item_description,
        name: catalogue_item_name
      } =
        valid_catalogue_item_attrs =
        Map.merge(@valid_attrs, %{brand_id: brand_id})

      some_item_variant =
        CatalogueItemVariantsFixtures.invalid_attrs(%{id: nil})

      valid_catalogue_item_variants_attrs = [
        {%CatalogueItemVariant{}, some_item_variant}
      ]

      assert {:error, {:catalogue_item_variant, 0}, changeset,
              %{
                catalogue_item: %CatalogueItem{
                  id: catalogue_item_id,
                  brand_id: ^catalogue_item_brand_id,
                  code: ^catalogue_item_code,
                  description: ^catalogue_item_description,
                  name: ^catalogue_item_name
                }
              }} =
               Offerings.create_assoc_catalogue_item(
                 {%CatalogueItem{}, valid_catalogue_item_attrs},
                 valid_catalogue_item_variants_attrs
               )

      refute changeset.valid?

      assert {"can't be blank", [validation: :required]} =
               Keyword.get(changeset.errors, :price)

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue_item!(catalogue_item_id)
      end
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

  describe "catalogue_item_variants" do
    alias ExCommerce.CatalogueItemsFixtures
    alias ExCommerce.Offerings.CatalogueItem
    alias ExCommerce.Offerings.CatalogueItemVariant

    @valid_attrs %{price: "120.5", type: "some type"}
    @update_attrs %{price: "456.7", type: "some updated type"}
    @invalid_attrs %{price: nil, type: nil}

    setup do
      %{catalogue_item: CatalogueItemsFixtures.create()}
    end

    def catalogue_item_variant_fixture(attrs \\ %{}) do
      {:ok, %CatalogueItemVariant{} = catalogue_item_variant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Offerings.create_catalogue_item_variant()

      catalogue_item_variant
    end

    test "list_catalogue_item_variants/0 returns all catalogue_item_variants",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      %CatalogueItemVariant{} =
        catalogue_item_variant =
        catalogue_item_variant_fixture(%{
          catalogue_item_id: catalogue_item_id
        })

      assert Offerings.list_catalogue_item_variants() == [
               catalogue_item_variant
             ]
    end

    test "get_catalogue_item_variant!/1 returns the catalogue_item_variant with given id",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      %CatalogueItemVariant{id: catalogue_item_variant_id} =
        catalogue_item_variant =
        catalogue_item_variant_fixture(%{catalogue_item_id: catalogue_item_id})

      assert Offerings.get_catalogue_item_variant!(catalogue_item_variant_id) ==
               catalogue_item_variant
    end

    test "create_catalogue_item_variant/1 with valid data creates a catalogue_item_variant",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      valid_attrs =
        Map.merge(@valid_attrs, %{catalogue_item_id: catalogue_item_id})

      assert {:ok, %CatalogueItemVariant{} = catalogue_item_variant} =
               Offerings.create_catalogue_item_variant(valid_attrs)

      assert catalogue_item_variant.price == Decimal.new(@valid_attrs.price)
      assert catalogue_item_variant.type == @valid_attrs.type
    end

    test "create_catalogue_item_variant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Offerings.create_catalogue_item_variant(@invalid_attrs)
    end

    test "update_catalogue_item_variant/2 with valid data updates the catalogue_item_variant",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      %CatalogueItemVariant{} =
        catalogue_item_variant =
        catalogue_item_variant_fixture(%{catalogue_item_id: catalogue_item_id})

      assert {:ok, %CatalogueItemVariant{} = catalogue_item_variant} =
               Offerings.update_catalogue_item_variant(
                 catalogue_item_variant,
                 @update_attrs
               )

      assert catalogue_item_variant.price == Decimal.new(@update_attrs.price)
      assert catalogue_item_variant.type == @update_attrs.type
    end

    test "update_catalogue_item_variant/2 with invalid data returns error changeset",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      %CatalogueItemVariant{id: catalogue_item_variant_id} =
        catalogue_item_variant =
        catalogue_item_variant_fixture(%{catalogue_item_id: catalogue_item_id})

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue_item_variant(
                 catalogue_item_variant,
                 @invalid_attrs
               )

      assert catalogue_item_variant ==
               Offerings.get_catalogue_item_variant!(catalogue_item_variant_id)
    end

    test "delete_catalogue_item_variant/1 deletes the catalogue_item_variant",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      %CatalogueItemVariant{id: catalogue_item_variant_id} =
        catalogue_item_variant =
        catalogue_item_variant_fixture(%{catalogue_item_id: catalogue_item_id})

      assert {:ok, %CatalogueItemVariant{}} =
               Offerings.delete_catalogue_item_variant(catalogue_item_variant)

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue_item_variant!(catalogue_item_variant_id)
      end
    end

    test "change_catalogue_item_variant/1 returns a catalogue_item_variant changeset",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      %CatalogueItemVariant{} =
        catalogue_item_variant =
        catalogue_item_variant_fixture(%{catalogue_item_id: catalogue_item_id})

      assert %Ecto.Changeset{} =
               Offerings.change_catalogue_item_variant(catalogue_item_variant)
    end
  end
end
