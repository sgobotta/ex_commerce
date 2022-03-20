defmodule ExCommerce.Seeds.Relations.CatalogueItemOptionGroupsItems do
  @moduledoc """
  Seeds for the CatalogueItemOptionGroupsItems model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file: "#{__DIR__}/catalogue_item_option_groups_items.json",
    plural_element: "catalogue_item_option_groups items",
    element_module: ExCommerce.Offerings.Relations.CatalogueItemOptionGroupItem,
    date_keys: [:inserted_at, :updated_at]
end
