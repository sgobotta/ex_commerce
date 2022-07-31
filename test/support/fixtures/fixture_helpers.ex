defmodule ExCommerce.FixtureHelpers do
  @moduledoc """
  Convenience module for reusable fixture functions
  """

  alias ExCommerce.{
    BrandsFixtures,
    CatalogueItemOptionGroup,
    CatalogueItemOptionGroupsFixtures,
    CatalogueItemsFixtures,
    CatalogueItemVariantsFixtures,
    CataloguesFixtures,
    ShopsFixtures
  }

  alias ExCommerce.Marketplaces.{Brand, Shop}

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueItem,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  @doc """
  Convenience function to assigning attributes for fixture creation. Whenever
  the desired attribute does not exist, a new fixture is created in order to
  satisfy the needed relationship.

  ## Examples:

      iex> maybe_assign(%{shop_id: "some id"}, :shop_id, Shop, ShopFixtures)
      %{shop_id: "some id"}

      iex> maybe_assign(%{}, :shop_id, Shop, ShopFixtures)
      %{shop_id: "some new id"}

  """
  @spec maybe_assign(map(), atom(), module(), module()) :: map()
  def maybe_assign(attrs, attr, struct_type, fixtures_module) do
    case Map.has_key?(attrs, attr) do
      false ->
        %^struct_type{id: id} = fixtures_module.create(attrs)
        Map.merge(attrs, %{attr => id})

      true ->
        attrs
    end
  end

  @doc """
  Convenience function to assign #{Brand} attributes through the
  #{BrandsFixtures} module.
  """
  @spec maybe_assign_brand(map()) :: map()
  def maybe_assign_brand(attrs),
    do: maybe_assign(attrs, :brand_id, Brand, BrandsFixtures)

  @doc """
  Convenience function to assign #{Shop} attributes through the
  #{ShopsFixtures} module.
  """
  @spec maybe_assign_shop(map()) :: map()
  def maybe_assign_shop(attrs),
    do: maybe_assign(attrs, :shop_id, Shop, ShopsFixtures)

  @doc """
  Convenience function to assign #{Catalogue} attributes through the
  #{CataloguesFixtures} module.
  """
  @spec maybe_assign_catalogue(map()) :: map()
  def maybe_assign_catalogue(attrs),
    do: maybe_assign(attrs, :catalogue_id, Catalogue, CataloguesFixtures)

  @doc """
  Convenience function to assign #{CatalogueItem} attributes through the
  #{CatalogueItemsFixtures} module.
  """
  @spec maybe_assign_catalogue_item(map()) :: map()
  def maybe_assign_catalogue_item(attrs),
    do:
      maybe_assign(
        attrs,
        :catalogue_item_id,
        CatalogueItem,
        CatalogueItemsFixtures
      )

  @doc """
  Convenience function to assign #{CatalogueItemVariant} attributes through the
  #{CatalogueItemVariantsFixtures} module.
  """
  @spec maybe_assign_catalogue_item_variant(map()) :: map()
  def maybe_assign_catalogue_item_variant(attrs),
    do:
      maybe_assign(
        attrs,
        :catalogue_item_option_group_id,
        CatalogueItemVariant,
        CatalogueItemVariantsFixtures
      )

  @doc """
  Convenience function to assign #{CatalogueItemOptionGroup} attributes through the
  #{CatalogueItemOptionGroupsFixtures} module.
  """
  @spec maybe_assign_catalogue_item_option_group(map()) :: map()
  def maybe_assign_catalogue_item_option_group(attrs),
    do:
      maybe_assign(
        attrs,
        :catalogue_item_option_group_id,
        CatalogueItemOptionGroup,
        CatalogueItemOptionGroupsFixtures
      )
end
