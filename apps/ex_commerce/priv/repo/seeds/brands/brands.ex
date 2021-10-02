defmodule ExCommerce.Seeds.Brands do
  @moduledoc """
  Seeds for the Brand model
  """

  alias ExCommerce.Repo
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Seeds.Utils

  require Logger

  @json_file "#{__DIR__}/brands.json"

  @spec populate :: :ok
  def populate do
    with {:ok, body} <- File.read(@json_file),
      {:ok, users} <- Jason.decode(body, keys: :atoms) do

      date_keys = [:inserted_at, :updated_at]
      brands = for user <- users do
        Map.merge(user, Utils.dates_to_naive_datetime(user, date_keys))
      end

      {count, _} = Repo.insert_all(Brand, brands)

      :ok = Logger.info("✅ Inserted #{count} brands.")

      :ok
    end
  end
end
