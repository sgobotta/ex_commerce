defmodule ExCommerceWeb.ResourceCases.MarketplacesCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require brands helpers.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.LiveViewTest

      alias ExCommerce.Accounts.User

      alias ExCommerce.{
        BrandsFixtures,
        CatalogueCategoriesFixtures,
        CatalogueItemsFixtures,
        CataloguesFixtures,
        ShopsFixtures
      }

      alias ExCommerce.Marketplaces
      alias ExCommerce.Marketplaces.{Brand, BrandUser, Shop}
      alias ExCommerce.Offerings
      alias ExCommerce.Offerings.{Catalogue, CatalogueCategory, CatalogueItem}

      defp create_shop(_context) do
        shop = ShopsFixtures.create()
        %{shop: shop}
      end

      defp create_brand(_context) do
        brand = BrandsFixtures.create()
        %{brand: brand}
      end

      defp create_catalogue(_context) do
        %{catalogue: CataloguesFixtures.create()}
      end

      defp create_catalogue_category(_context) do
        %{catalogue_category: CatalogueCategoriesFixtures.create()}
      end

      defp create_catalogue_item(_context) do
        %{catalogue_item: CatalogueItemsFixtures.create()}
      end

      defp assoc_user_brand(%{
             user: %User{id: user_id},
             brand: %Brand{id: brand_id}
           }) do
        {:ok, %BrandUser{} = _brand_user} =
          Marketplaces.create_brand_user(%{
            user_id: user_id,
            brand_id: brand_id
          })

        %{}
      end

      defp assoc_brand_shop(%{brand: %Brand{id: brand_id}, shop: %Shop{} = shop}) do
        {:ok, %Shop{} = shop} =
          Marketplaces.update_shop(shop, %{
            brand_id: brand_id
          })

        %{shop: shop}
      end

      defp assoc_brand_catalogue(%{
             brand: %Brand{id: brand_id},
             catalogue: %Catalogue{} = catalogue
           }) do
        {:ok, %Catalogue{} = catalogue} =
          Offerings.update_catalogue(catalogue, %{
            brand_id: brand_id
          })

        %{catalogue: catalogue}
      end

      defp assoc_brand_catalogue_category(%{
             brand: %Brand{id: brand_id},
             catalogue_category: %CatalogueCategory{} = catalogue_category
           }) do
        {:ok, %CatalogueCategory{} = catalogue_category} =
          Offerings.update_catalogue_category(catalogue_category, %{
            brand_id: brand_id
          })

        %{catalogue_category: catalogue_category}
      end

      defp assoc_brand_catalogue_item(%{
             brand: %Brand{id: brand_id},
             catalogue_item: %CatalogueItem{} = catalogue_item
           }) do
        {:ok, %CatalogueItem{} = catalogue_item} =
          Offerings.update_catalogue_item(catalogue_item, %{
            brand_id: brand_id
          })

        %{catalogue_item: catalogue_item}
      end

      defp assert_redirects_with_error(conn, from: from, to: to) do
        assert {:error, {:redirect, %{to: ^to}}} = live(conn, from)
      end
    end
  end
end
