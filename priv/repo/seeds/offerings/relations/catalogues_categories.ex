defmodule ExCommerce.Seeds.Offerings.Relations.CataloguesCategories do
  @moduledoc """
  Seeds for the ShopsCatalogues model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "offerings/relations/catalogues_categories.json",
    plural_element: "catalogues categories",
    element_module: ExCommerce.Offerings.Relations.CatalogueCategory,
    date_keys: [:inserted_at, :updated_at]
end
