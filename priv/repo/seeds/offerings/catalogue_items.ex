defmodule ExCommerce.Seeds.Offerings.CatalogueItems do
  @moduledoc """
  Seeds for the CatalogueItem model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "offerings/catalogue_items.json",
    plural_element: "catalogue items",
    element_module: ExCommerce.Offerings.CatalogueItem,
    date_keys: [:inserted_at, :updated_at]
end
