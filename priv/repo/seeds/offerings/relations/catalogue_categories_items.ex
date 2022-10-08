defmodule ExCommerce.Seeds.Relations.CataloguesCategoriesItems do
  @moduledoc """
  Seeds for the CataloguesCategoriesItems model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file: "#{__DIR__}/catalogue_categories_items.json",
    plural_element: "catalogue_categories items",
    element_module: ExCommerce.Offerings.Relations.CatalogueCategoryItem,
    date_keys: [:inserted_at, :updated_at]
end
