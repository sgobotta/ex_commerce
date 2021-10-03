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
end
