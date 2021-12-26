defmodule ExCommerceWeb.LiveFormHelpers do
  @moduledoc """
  Implements reusable helpers for live forms
  """

  @doc """
  Given a map of params and a brand id, merges the brand id into the params.
  """
  @spec assign_brand_id_param(map(), Ecto.UUID.t()) :: map()
  def assign_brand_id_param(%{"options" => options} = params, brand_id) do
    options =
      options
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, Map.merge(value, %{"brand_id" => brand_id}))
      end)

    Map.merge(params, %{"brand_id" => brand_id, "options" => options})
  end

  def assign_brand_id_param(params, brand_id),
    do: Map.merge(params, %{"brand_id" => brand_id})
end
