defmodule ExCommerce.Seeds.Marketplaces.Brands do
  @moduledoc """
  Seeds for the Brand model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "marketplaces/brands.json",
    plural_element: "brands",
    element_module: ExCommerce.Marketplaces.Brand,
    date_keys: [:inserted_at, :updated_at]
end
