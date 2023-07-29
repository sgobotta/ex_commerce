defmodule ExCommerce.Seeds.Offerings.CatalogueCategories do
  @moduledoc """
  Seeds for the CatalogueCategory model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "offerings/catalogue_categories.json",
    plural_element: "catalogue categories",
    element_module: ExCommerce.Offerings.CatalogueCategory,
    date_keys: [:inserted_at, :updated_at]
end
