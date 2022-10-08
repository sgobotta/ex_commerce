defmodule ExCommerce.Seeds.Relations.CataloguesCategories do
  @moduledoc """
  Seeds for the ShopsCatalogues model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file: "#{__DIR__}/catalogues_categories.json",
    plural_element: "catalogues categories",
    element_module: ExCommerce.Offerings.Relations.CatalogueCategory,
    date_keys: [:inserted_at, :updated_at]
end
