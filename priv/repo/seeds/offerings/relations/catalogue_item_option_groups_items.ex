defmodule ExCommerce.Seeds.Offerings.Relations.CatalogueItemOptionGroupsItems do
  @moduledoc """
  Seeds for the CatalogueItemOptionGroupsItems model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file_path: "offerings/relations/catalogue_item_option_groups_items.json",
    plural_element: "catalogue_item_option_groups items",
    element_module: ExCommerce.Offerings.Relations.CatalogueItemOptionGroupItem,
    date_keys: [:inserted_at, :updated_at]
end
