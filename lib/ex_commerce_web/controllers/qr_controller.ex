defmodule ExCommerceWeb.QrController do
  @moduledoc """
  Controller that receives requests from QR codes
  """
  use ExCommerceWeb, :controller

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.{Brand, Shop}
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.Catalogue

  alias ExCommerceWeb.Router.Helpers, as: Routes

  require Logger

  @doc """
  Receives request usually coming from QR codes.
  """
  @spec detour(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def detour(conn, params) do
    with {:ok, decoded_params} <- decode_params(params),
         {:ok, params} <- validate_params(decoded_params),
         {:ok, route} <- get_redirection_route(params["to"], params) do
      redirect(conn, to: route)
    else
      _error ->
        redirect(conn, to: "/")
    end
  rescue
    _error ->
      redirect(conn, to: "/")
  end

  # ----------------------------------------------------------------------------
  # Validation helpers

  @spec decode_params(map()) :: {:ok, map()}
  defp decode_params(params) do
    {:ok, params}
  end

  @spec validate_params(map()) :: {:ok, map()} | {:error, :not_found}
  defp validate_params(params) do
    with true <- Map.has_key?(params, "to"),
         true <- validate_route(params["to"], Map.delete(params, "to")) do
      {:ok, params}
    else
      _error ->
        {:error, :not_found}
    end
  end

  @spec validate_route(String.t(), map()) :: boolean()
  defp validate_route("checkout_shop", params),
    do: Map.has_key?(params, "brand_id") and Map.has_key?(params, "shop_id")

  defp validate_route("checkout_catalogue", params),
    do:
      Map.has_key?(params, "brand_id") and Map.has_key?(params, "shop_id") and
        Map.has_key?(params, "catalogue_id")

  defp validate_route(_route, _params), do: false

  # ----------------------------------------------------------------------------
  # Route helpers

  @spec get_redirection_route(String.t(), map()) ::
          {:ok, String.t()} | {:error, :not_found}
  defp get_redirection_route("checkout_shop", params) do
    with %Brand{slug: brand_slug} <-
           Marketplaces.get_brand!(params["brand_id"]),
         %Shop{slug: shop_slug} <- Marketplaces.get_shop!(params["shop_id"]) do
      {:ok,
       Routes.checkout_shop_path(
         ExCommerceWeb.Endpoint,
         :index,
         brand_slug,
         shop_slug
       )}
    else
      _error ->
        {:error, :not_found}
    end
  end

  defp get_redirection_route("checkout_catalogue", params) do
    with %Brand{slug: brand_slug} <-
           Marketplaces.get_brand!(params["brand_id"]),
         %Shop{slug: shop_slug} <- Marketplaces.get_shop!(params["shop_id"]),
         %Catalogue{id: catalogue_id} <-
           Offerings.get_catalogue!(params["catalogue_id"]) do
      {:ok,
       Routes.checkout_catalogue_path(
         ExCommerceWeb.Endpoint,
         :index,
         brand_slug,
         shop_slug,
         catalogue_id
       )}
    else
      _error ->
        {:error, :not_found}
    end
  end
end
