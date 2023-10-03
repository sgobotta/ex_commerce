defmodule ExCommerce.Seeds.Marketplaces.BrandsUsers do
  @moduledoc """
  Seeds for the Brands Users relationship model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "marketplaces/brands_users.json",
    plural_element: "brands users",
    element_module: ExCommerce.Marketplaces.BrandUser,
    date_keys: [:inserted_at, :updated_at]
end
