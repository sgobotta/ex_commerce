defmodule ExCommerce.Uploads.Relations.CatalogueItemPhotoFixtures do
  @moduledoc """
  This module defines test helpers for creating CatalogueItemPhoto
  entities via the `ExCommerce.Uploads.Relations` context.
  """

  alias ExCommerce.{
    Offerings,
    Uploads
  }

  alias ExCommerce.{
    CatalogueItemsFixtures,
    UploadsFixtures
  }

  @valid_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  @doc """
  Generate a catalogue_item_photo.
  """
  def create(attrs \\ %{}) do
    %Offerings.CatalogueItem{id: catalogue_item_id} =
      CatalogueItemsFixtures.create()

    %Uploads.Photo{id: photo_id} = UploadsFixtures.photo_fixture()

    {:ok, catalogue_item_photo} =
      attrs
      |> Enum.into(%{
        catalogue_item_id: catalogue_item_id,
        photo_id: photo_id
      })
      |> Uploads.Relations.create_catalogue_item_photo()

    catalogue_item_photo
  end
end
