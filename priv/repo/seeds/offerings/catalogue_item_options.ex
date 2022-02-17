defmodule ExCommerce.Seeds.CatalogueItemOptions do
  @moduledoc """
  Seeds for the CatalogueItemOption model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file: "#{__DIR__}/catalogue_item_options.json",
    plural_element: "catalogue item options",
    element_module: ExCommerce.Offerings.CatalogueItemOption,
    date_keys: [:inserted_at, :updated_at]
end
