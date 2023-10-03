defmodule ExCommerce.Seeds.Offerings.CatalogueItemOptionGroups do
  @moduledoc """
  Seeds for the CatalogueItemOptionGroup model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "offerings/catalogue_item_option_groups.json",
    plural_element: "catalogue item option groups",
    element_module: ExCommerce.Offerings.CatalogueItemOptionGroup,
    date_keys: [:inserted_at, :updated_at]
end
