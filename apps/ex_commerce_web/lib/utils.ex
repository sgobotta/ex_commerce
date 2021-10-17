defmodule ExCommerceWeb.Utils do
  @moduledoc """
  Convenience utilities for web forms, views and live views.
  """

  def get_temp_id,
    do: :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)
end
