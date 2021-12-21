defmodule ExCommerce.Seeds.Brands do
  @moduledoc """
  Seeds for the Brand model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file: "#{__DIR__}/brands.json",
    plural_element: "brands",
    element_module: ExCommerce.Marketplaces.Brand,
    date_keys: [:inserted_at, :updated_at]
end
