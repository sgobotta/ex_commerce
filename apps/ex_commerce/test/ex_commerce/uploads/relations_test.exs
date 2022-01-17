defmodule ExCommerce.Uploads.RelationsTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.Uploads.Relations

  describe "catalogue_items_photos" do
    alias ExCommerce.{Offerings, Uploads}

    alias ExCommerce.{CatalogueItemsFixtures, UploadsFixtures}

    alias ExCommerce.Uploads.Relations.CatalogueItemPhoto

    alias ExCommerce.Uploads.Relations.CatalogueItemPhotoFixtures

    @valid_attrs CatalogueItemPhotoFixtures.valid_attrs()
    @invalid_attrs %{catalogue_item_id: nil, photo_id: nil}

    test "list_catalogue_items_photos/0 returns all catalogue_items_photos" do
      %CatalogueItemPhoto{} =
        catalogue_item_photo = CatalogueItemPhotoFixtures.create()

      assert Relations.list_catalogue_items_photos() == [catalogue_item_photo]
    end

    test "get_catalogue_item_photo!/1 returns the catalogue_item_photo with given id" do
      %CatalogueItemPhoto{} =
        catalogue_item_photo = CatalogueItemPhotoFixtures.create()

      assert Relations.get_catalogue_item_photo!(catalogue_item_photo.id) ==
               catalogue_item_photo
    end

    test "create_catalogue_item_photo/1 with valid data creates a catalogue_item_photo" do
      %Offerings.CatalogueItem{id: catalogue_item_id} =
        CatalogueItemsFixtures.create()

      %Uploads.Photo{id: photo_id} = UploadsFixtures.photo_fixture()

      valid_attrs =
        Map.merge(@valid_attrs, %{
          catalogue_item_id: catalogue_item_id,
          photo_id: photo_id
        })

      assert {:ok, %CatalogueItemPhoto{} = _catalogue_item_photo} =
               Relations.create_catalogue_item_photo(valid_attrs)
    end

    test "create_catalogue_item_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Relations.create_catalogue_item_photo(@invalid_attrs)
    end

    test "update_catalogue_item_photo/2 with valid data updates the catalogue_item_photo" do
      %CatalogueItemPhoto{} =
        catalogue_item_photo = CatalogueItemPhotoFixtures.create()

      update_attrs = %{}

      assert {:ok, %CatalogueItemPhoto{} = _catalogue_item_photo} =
               Relations.update_catalogue_item_photo(
                 catalogue_item_photo,
                 update_attrs
               )
    end

    test "update_catalogue_item_photo/2 with invalid data returns error changeset" do
      %CatalogueItemPhoto{} =
        catalogue_item_photo = CatalogueItemPhotoFixtures.create()

      assert {:error, %Ecto.Changeset{}} =
               Relations.update_catalogue_item_photo(
                 catalogue_item_photo,
                 @invalid_attrs
               )

      assert catalogue_item_photo ==
               Relations.get_catalogue_item_photo!(catalogue_item_photo.id)
    end

    test "delete_catalogue_item_photo/1 deletes the catalogue_item_photo" do
      %CatalogueItemPhoto{} =
        catalogue_item_photo = CatalogueItemPhotoFixtures.create()

      assert {:ok, %CatalogueItemPhoto{}} =
               Relations.delete_catalogue_item_photo(catalogue_item_photo)

      assert_raise Ecto.NoResultsError, fn ->
        Relations.get_catalogue_item_photo!(catalogue_item_photo.id)
      end
    end

    test "change_catalogue_item_photo/1 returns a catalogue_item_photo changeset" do
      %CatalogueItemPhoto{} =
        catalogue_item_photo = CatalogueItemPhotoFixtures.create()

      assert %Ecto.Changeset{} =
               Relations.change_catalogue_item_photo(catalogue_item_photo)
    end
  end
end
