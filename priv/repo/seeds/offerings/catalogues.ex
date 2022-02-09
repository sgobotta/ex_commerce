defmodule ExCommerce.Seeds.Catalogues do
  @moduledoc """
  Seeds for the Catalogue model
  """

  use ExCommerce.Seeds.Utils,
    repo: ExCommerce.Repo,
    json_file: "#{__DIR__}/catalogues.json",
    plural_element: "catalogues",
    element_module: ExCommerce.Offerings.Catalogue,
    date_keys: [:inserted_at, :updated_at]
end
