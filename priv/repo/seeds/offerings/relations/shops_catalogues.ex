defmodule ExCommerce.Seeds.Offerings.Relations.ShopsCatalogues do
  @moduledoc """
  Seeds for the ShopsCatalogues model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "offerings/relations/shops_catalogues.json",
    plural_element: "shops catalogues",
    element_module: ExCommerce.Offerings.Relations.ShopCatalogue,
    date_keys: [:inserted_at, :updated_at]
end
