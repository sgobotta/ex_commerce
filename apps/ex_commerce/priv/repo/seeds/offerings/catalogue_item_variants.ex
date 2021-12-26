defmodule ExCommerce.Seeds.CatalogueItemVariants do
  @moduledoc """
  Seeds for the CatalogueItemVariant model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file: "#{__DIR__}/catalogue_item_variants.json",
    plural_element: "catalogue item variants",
    element_module: ExCommerce.Offerings.CatalogueItemVariant,
    date_keys: [:inserted_at, :updated_at]
end
