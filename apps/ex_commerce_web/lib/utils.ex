defmodule ExCommerceWeb.Utils do
  @moduledoc """
  Convenience utilities for web forms, views and live views.
  """

  @doc """
  Returns a random string. Mainly used to assign temporary ids to dom elements.
  """
  @spec get_temp_id :: binary
  def get_temp_id,
    do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

  @doc """
  Returns the path to the uploads directory
  """
  @spec get_uploads_path :: binary
  def get_uploads_path,
    do: Application.app_dir(:ex_commerce_web, "priv/static/uploads")
end
