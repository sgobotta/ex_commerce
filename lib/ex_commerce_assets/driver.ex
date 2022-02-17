defmodule ExCommerceAssets.Driver do
  @moduledoc """
  Generic behaviour module for Driver implementation.
  """

  require Logger

  @type t :: :test | :cloudex

  @doc """
  Takes a list of maps with file path and options to upload thumbnails.
  """
  @callback upload_thumbnails_with_options(list(map()), map()) :: list()

  @doc """
  Takes a list of maps with file path and options to upload images.
  """
  @callback upload_list_with_options(list(map()), map()) :: list()
end
