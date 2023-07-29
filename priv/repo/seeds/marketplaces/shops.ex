defmodule ExCommerce.Seeds.Marketplaces.Shops do
  @moduledoc """
  Seeds for the Shop model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "marketplaces/shops.json",
    plural_element: "shops",
    element_module: ExCommerce.Marketplaces.Shop,
    date_keys: [:inserted_at, :updated_at]
end
