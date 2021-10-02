defmodule ExCommerce.Seeds.BrandsUsers do
  @moduledoc """
  Seeds for the Brands Users relationship model
  """

  alias ExCommerce.Repo
  alias ExCommerce.Marketplaces.BrandUser
  alias ExCommerce.Seeds.Utils

  require Logger

  @json_file "#{__DIR__}/brands_users.json"

  @spec populate :: :ok
  def populate do
    with {:ok, body} <- File.read(@json_file),
      {:ok, decoded_elements} <- Jason.decode(body, keys: :atoms) do

      date_keys = [:inserted_at, :updated_at]
      elements = for element <- decoded_elements do
        Map.merge(element, Utils.dates_to_naive_datetime(element, date_keys))
      end

      {count, _} = Repo.insert_all(BrandUser, elements)

      :ok = Logger.info("✅ Inserted #{count} brands users.")

      :ok
    end
  end
end
