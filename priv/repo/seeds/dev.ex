defmodule ExCommerce.Seeds.Dev do
  @moduledoc """
  Runs development fixtures.
  """

  require Logger

  alias ExCommerce.Seeds.{
    Brands,
    BrandsUsers,
    CatalogueCategories,
    CatalogueItemOptionGroups,
    CatalogueItemOptions,
    CatalogueItems,
    CatalogueItemVariants,
    Catalogues,
    Relations,
    Shops,
    Users
  }

  @spec populate :: :ok
  def populate do
    # Removes debug messages in this run
    :ok = Logger.configure(level: :info)

    :ok = Logger.info("📌 Starting seeds population process...")

    # Run seeds here
    :ok = Users.populate()
    :ok = Brands.populate()
    :ok = BrandsUsers.populate()
    :ok = Shops.populate()
    :ok = Catalogues.populate()
    :ok = CatalogueCategories.populate()
    :ok = CatalogueItems.populate()
    :ok = CatalogueItemVariants.populate()
    :ok = CatalogueItemOptionGroups.populate()
    :ok = CatalogueItemOptions.populate()

    :ok = Relations.ShopsCatalogues.populate()
    :ok = Relations.CataloguesCategories.populate()
    :ok = Relations.CataloguesCategoriesItems.populate()
    :ok = Relations.CatalogueItemOptionGroupsItems.populate()

    :ok = Logger.info("🌱 Succesfully created development seeds.")

    :ok
  end
end
