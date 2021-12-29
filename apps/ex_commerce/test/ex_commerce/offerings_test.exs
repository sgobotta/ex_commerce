defmodule ExCommerce.OfferingsTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.Offerings
  alias ExCommerce.Repo

  describe "catalogues" do
    alias ExCommerce.{BrandsFixtures, CataloguesFixtures}

    alias ExCommerce.Marketplaces.Brand
    alias ExCommerce.Offerings.Catalogue

    @valid_attrs CataloguesFixtures.valid_attrs()
    @update_attrs CataloguesFixtures.update_attrs()
    @invalid_attrs CataloguesFixtures.invalid_attrs()

    setup do
      %{brand: BrandsFixtures.create()}
    end

    test "list_catalogues/0 returns all catalogues", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{} =
        catalogue = CataloguesFixtures.create(%{brand_id: brand_id})

      assert Offerings.list_catalogues()
             |> Repo.preload([:categories]) == [catalogue]
    end

    test "list_catalogues_by_brand/1 returns all catalogues for a given brand",
         %{
           brand: %Brand{id: brand_id}
         } do
      %Catalogue{} =
        catalogue = CataloguesFixtures.create(%{brand_id: brand_id})

      assert Offerings.list_catalogues_by_brand(brand_id)
             |> Repo.preload([:categories]) == [catalogue]
    end

    test "get_catalogue!/1 returns the catalogue with given id", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{id: catalogue_id} =
        catalogue = CataloguesFixtures.create(%{brand_id: brand_id})

      assert Offerings.get_catalogue!(catalogue_id)
             |> Repo.preload([:categories]) == catalogue
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
      %Catalogue{} =
        catalogue = CataloguesFixtures.create(%{brand_id: brand_id})

      assert {:ok, %Catalogue{} = catalogue} =
               Offerings.update_catalogue(catalogue, @update_attrs)

      assert catalogue.name == @update_attrs.name
    end

    test "update_catalogue/2 with invalid data returns error changeset", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{id: catalogue_id} =
        catalogue = CataloguesFixtures.create(%{brand_id: brand_id})

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue(catalogue, @invalid_attrs)

      assert catalogue ==
               Offerings.get_catalogue!(catalogue_id)
               |> Repo.preload([:categories])
    end

    test "delete_catalogue/1 deletes the catalogue", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{id: catalogue_id} =
        catalogue = CataloguesFixtures.create(%{brand_id: brand_id})

      assert {:ok, %Catalogue{}} = Offerings.delete_catalogue(catalogue)

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue!(catalogue_id)
      end
    end

    test "change_catalogue/1 returns a catalogue changeset", %{
      brand: %Brand{id: brand_id}
    } do
      %Catalogue{} =
        catalogue = CataloguesFixtures.create(%{brand_id: brand_id})

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

      assert Offerings.list_catalogue_categories()
             |> Repo.preload([:items, :catalogues]) ==
               [catalogue_category]
    end

    test "list_catalogue_categories_by_brand/1 returns all catalogue_categories for a given brand",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueCategory{} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert Offerings.list_catalogue_categories_by_brand(brand_id)
             |> Repo.preload([:items, :catalogues]) == [
               catalogue_category
             ]
    end

    test "get_catalogue_category!/1 returns the catalogue_category with given id",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueCategory{id: catalogue_category_id} =
        catalogue_category = catalogue_category_fixture(%{brand_id: brand_id})

      assert Offerings.get_catalogue_category!(catalogue_category_id)
             |> Repo.preload([:items, :catalogues]) ==
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

      assert catalogue_category |> Repo.preload([:items]) ==
               Offerings.get_catalogue_category!(catalogue_category_id)
               |> Repo.preload([:items, :catalogues])
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

      assert Enum.map(
               Offerings.list_catalogue_items(),
               &Repo.preload(&1, [:categories, :option_groups])
             ) == [catalogue_item]
    end

    test "list_catalogue_items_by_brand/1 returns all catalogue_items for a given brand",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItem{} =
        catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})

      assert Enum.map(
               Offerings.list_catalogue_items_by_brand(brand_id),
               &Repo.preload(&1, [:categories, :option_groups])
             ) == [
               catalogue_item
             ]
    end

    test "get_catalogue_item!/1 returns the catalogue_item with given id", %{
      brand: %Brand{id: brand_id}
    } do
      %CatalogueItem{id: catalogue_item_id} =
        catalogue_item = catalogue_item_fixture(%{brand_id: brand_id})

      assert Offerings.get_catalogue_item!(catalogue_item_id)
             |> Repo.preload([:categories, :option_groups]) == catalogue_item
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
      assert Offerings.get_catalogue_item!(catalogue_item_id)
             |> Repo.preload([:categories, :option_groups]) == catalogue_item

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
      assert Offerings.get_catalogue_item!(catalogue_item_id)
             |> Repo.preload([:categories, :option_groups]) ==
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

      assert catalogue_item ==
               Offerings.get_catalogue_item!(catalogue_item_id)
               |> Repo.preload([:categories, :option_groups])
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
    alias ExCommerce.{
      CatalogueItemsFixtures,
      CatalogueItemVariantsFixtures
    }

    alias ExCommerce.Offerings.{
      CatalogueItem,
      CatalogueItemVariant
    }

    @valid_attrs CatalogueItemVariantsFixtures.valid_attrs()
    @update_attrs CatalogueItemVariantsFixtures.update_attrs()
    @invalid_attrs CatalogueItemVariantsFixtures.invalid_attrs()

    setup do
      %{catalogue_item: CatalogueItemsFixtures.create()}
    end

    test "list_catalogue_item_variants/0 returns all catalogue_item_variants",
         %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} do
      %CatalogueItemVariant{} =
        catalogue_item_variant =
        CatalogueItemVariantsFixtures.create(%{
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
        CatalogueItemVariantsFixtures.create(%{
          catalogue_item_id: catalogue_item_id
        })

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
        CatalogueItemVariantsFixtures.create(%{
          catalogue_item_id: catalogue_item_id
        })

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
        CatalogueItemVariantsFixtures.create(%{
          catalogue_item_id: catalogue_item_id
        })

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
        CatalogueItemVariantsFixtures.create(%{
          catalogue_item_id: catalogue_item_id
        })

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
        CatalogueItemVariantsFixtures.create(%{
          catalogue_item_id: catalogue_item_id
        })

      assert %Ecto.Changeset{} =
               Offerings.change_catalogue_item_variant(catalogue_item_variant)
    end
  end

  describe "catalogue_item_options" do
    alias ExCommerce.{
      BrandsFixtures,
      CatalogueItemsFixtures,
      CatalogueItemVariantsFixtures
    }

    alias ExCommerce.Marketplaces.Brand

    alias ExCommerce.Offerings.{
      CatalogueItem,
      CatalogueItemOption,
      CatalogueItemVariant
    }

    @valid_attrs %{is_visible: true, price_modifier: "120.5"}
    @update_attrs %{is_visible: false, price_modifier: "456.7"}
    @invalid_attrs %{is_visible: nil, price_modifier: nil}

    setup do
      %Brand{id: brand_id} = brand = BrandsFixtures.create()

      %{
        brand: brand,
        catalogue_item: CatalogueItemsFixtures.create(%{brand_id: brand_id}),
        catalogue_item_variant: CatalogueItemVariantsFixtures.create()
      }
    end

    def catalogue_item_option_fixture(attrs \\ %{}) do
      {:ok, %CatalogueItemOption{} = catalogue_item_option} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Offerings.create_catalogue_item_option()

      catalogue_item_option
    end

    defp preload_fields(catalogue_item_option) do
      Repo.preload(catalogue_item_option, [
        :catalogue_item,
        :catalogue_item_variant
      ])
    end

    test "list_catalogue_item_options/0 returns all catalogue_item_options", %{
      brand: %Brand{id: brand_id},
      catalogue_item: item,
      catalogue_item_variant: variant
    } do
      %CatalogueItemOption{} =
        catalogue_item_option =
        catalogue_item_option_fixture(%{
          brand_id: brand_id,
          catalogue_item_id: item.id,
          catalogue_item_variant_id: variant.id
        })

      assert Offerings.list_catalogue_item_options()
             |> preload_fields() == [
               preload_fields(catalogue_item_option)
             ]
    end

    test "get_catalogue_item_option!/1 returns the catalogue_item_option with given id",
         %{
           brand: %Brand{id: brand_id},
           catalogue_item: item,
           catalogue_item_variant: variant
         } do
      %CatalogueItemOption{id: catalogue_item_option_id} =
        catalogue_item_option =
        catalogue_item_option_fixture(%{
          brand_id: brand_id,
          catalogue_item_id: item.id,
          catalogue_item_variant_id: variant.id
        })

      assert Offerings.get_catalogue_item_option!(catalogue_item_option_id)
             |> preload_fields() ==
               preload_fields(catalogue_item_option)
    end

    test "create_catalogue_item_option/1 with valid data creates a catalogue_item_option",
         %{
           brand: %Brand{id: brand_id},
           catalogue_item: item,
           catalogue_item_variant: variant
         } do
      valid_attrs =
        Map.merge(@valid_attrs, %{
          brand_id: brand_id,
          catalogue_item_id: item.id,
          catalogue_item_variant_id: variant.id
        })

      assert {:ok,
              %CatalogueItemOption{
                is_visible: is_visible,
                price_modifier: price_modifier
              }} = Offerings.create_catalogue_item_option(valid_attrs)

      assert is_visible == true
      assert price_modifier == Decimal.new("120.5")
    end

    test "create_catalogue_item_option/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Offerings.create_catalogue_item_option(@invalid_attrs)
    end

    test "update_catalogue_item_option/2 with valid data updates the catalogue_item_option",
         %{
           brand: %Brand{id: brand_id},
           catalogue_item: item,
           catalogue_item_variant: variant
         } do
      %CatalogueItemOption{} =
        catalogue_item_option =
        catalogue_item_option_fixture(%{
          brand_id: brand_id,
          catalogue_item_id: item.id,
          catalogue_item_variant_id: variant.id
        })

      assert {:ok,
              %CatalogueItemOption{
                is_visible: is_visible,
                price_modifier: price_modifier
              }} =
               Offerings.update_catalogue_item_option(
                 catalogue_item_option,
                 @update_attrs
               )

      assert is_visible == false
      assert price_modifier == Decimal.new("456.7")
    end

    @tag :skip
    test "update_catalogue_item_option/2 with invalid data returns error changeset",
         %{
           brand: %Brand{id: brand_id},
           catalogue_item: item,
           catalogue_item_variant: variant
         } do
      %CatalogueItemOption{id: catalogue_item_option_id} =
        catalogue_item_option =
        catalogue_item_option_fixture(%{
          brand_id: brand_id,
          catalogue_item_id: item.id,
          catalogue_item_variant_id: variant.id
        })

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue_item_option(
                 catalogue_item_option,
                 @invalid_attrs
               )

      assert catalogue_item_option ==
               Offerings.get_catalogue_item_option!(catalogue_item_option_id)
               |> Repo.preload([:catalogue_item, :catalogue_item_variant])
    end

    test "delete_catalogue_item_option/1 deletes the catalogue_item_option", %{
      brand: %Brand{id: brand_id},
      catalogue_item: item,
      catalogue_item_variant: variant
    } do
      %CatalogueItemOption{id: catalogue_item_option_id} =
        catalogue_item_option =
        catalogue_item_option_fixture(%{
          brand_id: brand_id,
          catalogue_item_id: item.id,
          catalogue_item_variant_id: variant.id
        })

      assert {:ok, %CatalogueItemOption{}} =
               Offerings.delete_catalogue_item_option(catalogue_item_option)

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue_item_option!(catalogue_item_option_id)
      end
    end

    test "change_catalogue_item_option/1 returns a catalogue_item_option changeset",
         %{
           brand: %Brand{id: brand_id},
           catalogue_item: item,
           catalogue_item_variant: variant
         } do
      %CatalogueItemOption{} =
        catalogue_item_option =
        catalogue_item_option_fixture(%{
          brand_id: brand_id,
          catalogue_item_id: item.id,
          catalogue_item_variant_id: variant.id
        })

      assert %Ecto.Changeset{} =
               Offerings.change_catalogue_item_option(catalogue_item_option)
    end
  end

  describe "catalogue_item_option_groups" do
    alias ExCommerce.BrandsFixtures

    alias ExCommerce.Marketplaces.Brand

    alias ExCommerce.Offerings.CatalogueItemOptionGroup

    alias ExCommerce.CatalogueItemOptionGroupsFixtures

    @valid_attrs CatalogueItemOptionGroupsFixtures.valid_attrs()
    @update_attrs CatalogueItemOptionGroupsFixtures.update_attrs()
    @invalid_attrs CatalogueItemOptionGroupsFixtures.invalid_attrs()

    setup do
      %Brand{} = brand = BrandsFixtures.create()

      %{brand: brand}
    end

    test "list_catalogue_item_option_groups/0 returns all catalogue_item_option_groups",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItemOptionGroup{} =
        catalogue_item_option_group =
        CatalogueItemOptionGroupsFixtures.create(%{
          brand_id: brand_id
        })

      assert Offerings.list_catalogue_item_option_groups()
             |> Repo.preload([:items]) == [
               catalogue_item_option_group
             ]
    end

    test "get_catalogue_item_option_group!/1 returns the catalogue_item_option_group with given id",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItemOptionGroup{id: catalogue_item_option_group_id} =
        catalogue_item_option_group =
        CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})

      assert Offerings.get_catalogue_item_option_group!(
               catalogue_item_option_group_id
             )
             |> Repo.preload([:items]) == catalogue_item_option_group
    end

    test "create_catalogue_item_option_group/1 with valid data creates a catalogue_item_option_group",
         %{
           brand: %Brand{id: brand_id}
         } do
      valid_attrs = Map.merge(@valid_attrs, %{brand_id: brand_id})

      assert {:ok, %CatalogueItemOptionGroup{} = catalogue_item_option_group} =
               Offerings.create_catalogue_item_option_group(valid_attrs)

      assert catalogue_item_option_group.mandatory == true
      assert catalogue_item_option_group.max_selection == 42
      assert catalogue_item_option_group.multiple_selection == true
    end

    test "create_catalogue_item_option_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Offerings.create_catalogue_item_option_group(@invalid_attrs)
    end

    test "update_catalogue_item_option_group/2 with valid data updates the catalogue_item_option_group",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItemOptionGroup{} =
        catalogue_item_option_group =
        CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})

      assert {:ok, %CatalogueItemOptionGroup{} = catalogue_item_option_group} =
               Offerings.update_catalogue_item_option_group(
                 catalogue_item_option_group,
                 @update_attrs
               )

      assert catalogue_item_option_group.mandatory == false
      assert catalogue_item_option_group.max_selection == 43
      assert catalogue_item_option_group.multiple_selection == false
    end

    test "update_catalogue_item_option_group/2 with invalid data returns error changeset",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItemOptionGroup{id: catalogue_item_option_group_id} =
        catalogue_item_option_group =
        CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue_item_option_group(
                 catalogue_item_option_group,
                 @invalid_attrs
               )

      assert catalogue_item_option_group ==
               Offerings.get_catalogue_item_option_group!(
                 catalogue_item_option_group_id
               )
               |> Repo.preload([:items])
    end

    test "delete_catalogue_item_option_group/1 deletes the catalogue_item_option_group",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItemOptionGroup{id: catalogue_item_option_group_id} =
        catalogue_item_option_group =
        CatalogueItemOptionGroupsFixtures.create(%{brand_id: brand_id})

      assert {:ok, %CatalogueItemOptionGroup{}} =
               Offerings.delete_catalogue_item_option_group(
                 catalogue_item_option_group
               )

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue_item_option_group!(
          catalogue_item_option_group_id
        )
      end
    end

    test "change_catalogue_item_option_group/1 returns a catalogue_item_option_group changeset",
         %{
           brand: %Brand{id: brand_id}
         } do
      %CatalogueItemOptionGroup{} =
        catalogue_item_option_group =
        CatalogueItemOptionGroupsFixtures.create(%{
          brand_id: brand_id
        })

      assert %Ecto.Changeset{} =
               Offerings.change_catalogue_item_option_group(
                 catalogue_item_option_group
               )
    end
  end

  describe "catalogue_item_option_groups_items" do
    alias ExCommerce.{CatalogueItemOptionGroupsFixtures, CatalogueItemsFixtures}

    alias ExCommerce.Offerings.{
      CatalogueItem,
      CatalogueItemOptionGroup
    }

    alias ExCommerce.Offerings.Relations.CatalogueItemOptionGroupItem

    @valid_attrs %{visible: true}
    @update_attrs %{visible: false}
    @invalid_attrs %{visible: nil}

    def catalogue_item_option_group_item_fixture(attrs \\ %{}) do
      %CatalogueItem{id: item_id} = CatalogueItemsFixtures.create()

      %CatalogueItemOptionGroup{id: option_group_id} =
        CatalogueItemOptionGroupsFixtures.create()

      {:ok, %CatalogueItemOptionGroupItem{} = item_option_group_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{
          catalogue_item_id: item_id,
          catalogue_item_option_group_id: option_group_id
        })
        |> Offerings.create_catalogue_item_option_group_item()

      item_option_group_item
    end

    test "list_catalogue_item_option_groups_items/0 returns all catalogue_item_option_groups_items" do
      catalogue_item_option_group_item =
        catalogue_item_option_group_item_fixture()

      assert Offerings.list_catalogue_item_option_groups_items() == [
               catalogue_item_option_group_item
             ]
    end

    test "get_catalogue_item_option_group_item!/1 returns the catalogue_item_option_group_item with given id" do
      catalogue_item_option_group_item =
        catalogue_item_option_group_item_fixture()

      assert Offerings.get_catalogue_item_option_group_item!(
               catalogue_item_option_group_item.id
             ) == catalogue_item_option_group_item
    end

    test "create_catalogue_item_option_group_item/1 with valid data creates a catalogue_item_option_group_item" do
      %CatalogueItem{id: item_id} = CatalogueItemsFixtures.create()

      %CatalogueItemOptionGroup{id: option_group_id} =
        CatalogueItemOptionGroupsFixtures.create()

      valid_attrs =
        Map.merge(@valid_attrs, %{
          catalogue_item_id: item_id,
          catalogue_item_option_group_id: option_group_id
        })

      assert {:ok, %CatalogueItemOptionGroupItem{visible: visible}} =
               Offerings.create_catalogue_item_option_group_item(valid_attrs)

      assert visible
    end

    test "create_catalogue_item_option_group_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Offerings.create_catalogue_item_option_group_item(@invalid_attrs)
    end

    test "update_catalogue_item_option_group_item/2 with valid data updates the catalogue_item_option_group_item" do
      catalogue_item_option_group_item =
        catalogue_item_option_group_item_fixture()

      assert {:ok, %CatalogueItemOptionGroupItem{visible: visible}} =
               Offerings.update_catalogue_item_option_group_item(
                 catalogue_item_option_group_item,
                 @update_attrs
               )

      refute visible
    end

    test "update_catalogue_item_option_group_item/2 with invalid data returns error changeset" do
      catalogue_item_option_group_item =
        catalogue_item_option_group_item_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Offerings.update_catalogue_item_option_group_item(
                 catalogue_item_option_group_item,
                 @invalid_attrs
               )

      assert catalogue_item_option_group_item ==
               Offerings.get_catalogue_item_option_group_item!(
                 catalogue_item_option_group_item.id
               )
    end

    test "delete_catalogue_item_option_group_item/1 deletes the catalogue_item_option_group_item" do
      catalogue_item_option_group_item =
        catalogue_item_option_group_item_fixture()

      assert {:ok, %CatalogueItemOptionGroupItem{}} =
               Offerings.delete_catalogue_item_option_group_item(
                 catalogue_item_option_group_item
               )

      assert_raise Ecto.NoResultsError, fn ->
        Offerings.get_catalogue_item_option_group_item!(
          catalogue_item_option_group_item.id
        )
      end
    end

    test "change_catalogue_item_option_group_item/1 returns a catalogue_item_option_group_item changeset" do
      catalogue_item_option_group_item =
        catalogue_item_option_group_item_fixture()

      assert %Ecto.Changeset{} =
               Offerings.change_catalogue_item_option_group_item(
                 catalogue_item_option_group_item
               )
    end
  end
end
