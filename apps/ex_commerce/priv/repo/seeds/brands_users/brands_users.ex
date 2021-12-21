defmodule ExCommerce.Seeds.BrandsUsers do
  @moduledoc """
  Seeds for the Brands Users relationship model
  """

  alias ExCommerce.Repo
  alias ExCommerce.Marketplaces.BrandUser
  alias ExCommerce.Seeds.Utils

  require Logger

  @json_file "#{__DIR__}/brands_users.json"

  @plural_element "brands users"
  @element_module BrandUser

  @date_keys [:inserted_at, :updated_at]

  @spec populate :: :ok
  def populate do
    with {:ok, body} <- File.read(@json_file),
      {:ok, elements} <- Jason.decode(body, keys: :atoms) do

      elements = for element <- elements do
        Map.merge(element, Utils.dates_to_naive_datetime(element, @date_keys))
      end

      {count, _} = Repo.insert_all(@element_module, elements)

      :ok = Logger.info("✅ Inserted #{count} #{@plural_element}.")

      :ok
    end
  end
end
