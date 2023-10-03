defmodule ExCommerce.Seeds.Offerings.CatalogueItemVariants do
  @moduledoc """
  Seeds for the CatalogueItemVariant model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "offerings/catalogue_item_variants.json",
    plural_element: "catalogue item variants",
    element_module: ExCommerce.Offerings.CatalogueItemVariant,
    date_keys: [:inserted_at, :updated_at]
end
