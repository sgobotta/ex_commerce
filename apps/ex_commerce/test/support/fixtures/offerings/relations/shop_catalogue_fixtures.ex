defmodule ExCommerce.Offerings.Relations.ShopCatalogueFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Offerings.Relations.ShopCatalogue` context.
  """

  alias ExCommerce.{Marketplaces, Offerings}

  alias ExCommerce.{CataloguesFixtures, ShopsFixtures}

  alias ExCommerce.Offerings.Relations.ShopCatalogue

  @valid_attrs %{visible: true}
  @update_attrs %{visible: false}
  @invalid_attrs %{visible: nil}

  def valid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@valid_attrs)
  def update_attrs(attrs \\ %{}), do: attrs |> Enum.into(@update_attrs)
  def invalid_attrs(attrs \\ %{}), do: attrs |> Enum.into(@invalid_attrs)

  @doc """
  Generate a shop_catalogue.
  """
  def create(attrs \\ %{}) do
    %Offerings.Catalogue{id: catalogue_id} = CataloguesFixtures.create(attrs)

    %Marketplaces.Shop{id: shop_id} = ShopsFixtures.create(attrs)

    {:ok, %ShopCatalogue{} = shop_catalogue} =
      attrs
      |> Enum.into(%{
        catalogue_id: catalogue_id,
        shop_id: shop_id
      })
      |> Offerings.Relations.create_shop_catalogue()

    shop_catalogue
  end
end
