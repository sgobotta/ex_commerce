defmodule ExCommerceAssets do
  @moduledoc """
  `ExCommerceAssets` is a wrapper for assets uploading services.
  """

  @doc """
  Takes a list of items, a map with options and delegates the call to the
  configured driver and finally upload thumbnails.
  """
  @spec upload_thumbnails_with_options(list(map), map) :: list()
  def upload_thumbnails_with_options(items, options) do
    driver(get_driver()).upload_thumbnails_with_options(items, options)
  end

  @doc """
  Takes a list of items, a map with options and delegates the call to the
  configured driver and finally upload images.
  """
  @spec upload_list_with_options(list(map), map) :: list()
  def upload_list_with_options(items, options) do
    driver(get_driver()).upload_list_with_options(items, options)
  end

  defp get_driver,
    do: Application.get_env(:ex_commerce, :ex_commerce_assets_driver, :cloudex)

  defp driver(:cloudex), do: ExCommerceAssets.Drivers.CloudexDriver
  defp driver(:test), do: ExCommerceAssets.Drivers.TestDriver
end
