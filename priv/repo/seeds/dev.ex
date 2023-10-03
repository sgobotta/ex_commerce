defmodule ExCommerce.Seeds.Dev do
  @moduledoc """
  Runs development fixtures.
  """

  require Logger

  alias ExCommerce.Seeds.{
    Accounts,
    Marketplaces,
    Offerings
  }

  @spec populate :: :ok
  def populate do
    # Removes debug messages in this run
    :ok = Logger.configure(level: :info)

    :ok = Logger.info("📌 Starting seeds population process...")

    # Run seeds here
    :ok = Accounts.Users.populate()
    :ok = Marketplaces.Brands.populate()
    :ok = Marketplaces.BrandsUsers.populate()
    :ok = Marketplaces.Shops.populate()
    :ok = Offerings.Catalogues.populate()
    :ok = Offerings.CatalogueCategories.populate()
    :ok = Offerings.CatalogueItems.populate()
    :ok = Offerings.CatalogueItemVariants.populate()
    :ok = Offerings.CatalogueItemOptionGroups.populate()
    :ok = Offerings.CatalogueItemOptions.populate()
    :ok = Offerings.Relations.ShopsCatalogues.populate()
    :ok = Offerings.Relations.CataloguesCategories.populate()
    :ok = Offerings.Relations.CataloguesCategoriesItems.populate()
    :ok = Offerings.Relations.CatalogueItemOptionGroupsItems.populate()

    :ok = Logger.info("🌱 Finished seeds creation for dev environment.")

    :ok
  end
end
