defmodule ExCommerceWeb.ResourceCases.MarketplacesCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require brands helpers.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with brands

      alias ExCommerce.Accounts.User
      alias ExCommerce.Marketplaces
      alias ExCommerce.Marketplaces.Brand
      alias ExCommerce.Marketplaces.Shop

      defp assoc_user_brand(%{
             user: %User{id: user_id},
             brand: %Brand{id: brand_id}
           }) do
        {:ok, _brand_user} =
          Marketplaces.create_brand_user(%{
            user_id: user_id,
            brand_id: brand_id
          })

        %{}
      end

      defp assoc_brand_shop(%{brand: %Brand{id: brand_id}, shop: %Shop{} = shop}) do
        {:ok, shop} =
          Marketplaces.update_shop(shop, %{
            brand_id: brand_id
          })

        %{shop: shop}
      end
    end
  end
end
