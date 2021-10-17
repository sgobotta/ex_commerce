defmodule ExCommerce.ContextCases.OfferingsCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require Offerings helpers.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias ExCommerce.{
        CatalogueCategoriesFixtures,
        CatalogueItemsFixtures,
        CataloguesFixtures
      }

      alias ExCommerce.Marketplaces.Brand
      alias ExCommerce.Offerings

      alias ExCommerce.Offerings.{
        Catalogue,
        CatalogueCategory,
        CatalogueItem,
        CatalogueItemVariant
      }

      defp create_catalogue(_context) do
        %{catalogue: CataloguesFixtures.create()}
      end

      defp create_catalogue_category(_context) do
        %{catalogue_category: CatalogueCategoriesFixtures.create()}
      end

      defp create_catalogue_item(_context) do
        %{catalogue_item: CatalogueItemsFixtures.create()}
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
    end
  end
end
