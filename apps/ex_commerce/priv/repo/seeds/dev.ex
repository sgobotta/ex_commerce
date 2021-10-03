defmodule ExCommerce.Seeds.Dev do
  @moduledoc """
  Runs development fixtures.
  """

  require Logger

  alias ExCommerce.Seeds.{
    Brands,
    BrandsUsers,
    Catalogues,
    CatalogueCategories,
    CatalogueItems,
    Shops,
    Users
  }

  @spec populate :: :ok
  def populate do
    # Run seeds here
    :ok = Users.populate()
    :ok = Brands.populate()
    :ok = BrandsUsers.populate()
    :ok = Shops.populate()
    :ok = Catalogues.populate()
    :ok = CatalogueCategories.populate()
    :ok = CatalogueItems.populate()

    :ok = Logger.info("🌱 Succesfully created development seeds.")

    :ok
  end
end
