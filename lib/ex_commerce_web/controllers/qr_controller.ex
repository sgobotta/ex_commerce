defmodule ExCommerceWeb.QrController do
  @moduledoc """
  Controller that receives requests from QR codes
  """
  use ExCommerceWeb, :controller

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.{Brand, Shop}
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.Catalogue
  alias ExCommerce.QrCodes

  alias ExCommerceWeb.Router.Helpers, as: Routes

  require Logger

  @doc """
  Receives request usually coming from QR codes.
  """
  @spec detour(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def detour(conn, params) do
    with {:ok, decoded_params} <- decode_args(params["args"]),
         {:ok, validated_params} <- validate_params(decoded_params),
         {:ok, route} <-
           get_redirection_route(validated_params["to"], validated_params) do
      redirect(conn, to: route)
    else
      error ->
        Logger.debug(
          "Handled error on :detour action error=#{inspect(error, pretty: true)} params=#{inspect(params, pretty: true)}"
        )

        redirect(conn, to: "/")
    end
  rescue
    error ->
      Logger.debug(
        "Error thrown on :detour action error=#{inspect(error, pretty: true)} params=#{inspect(params, pretty: true)}"
      )

      redirect(conn, to: "/")
  end

  # ----------------------------------------------------------------------------
  # Validation helpers

  @spec decode_args(String.t() | nil) ::
          {:ok, map()} | {:error, :decode_error, reason :: binary()}
  defp decode_args(nil), do: {:error, :invalid_args}

  defp decode_args(encoded_args), do: QrCodes.decode_args(encoded_args)

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
