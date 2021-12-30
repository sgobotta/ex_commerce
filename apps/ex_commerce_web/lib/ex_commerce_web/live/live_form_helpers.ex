defmodule ExCommerceWeb.LiveFormHelpers do
  @moduledoc """
  Implements reusable helpers for live forms
  """

  alias Phoenix.LiveView

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

  @doc """
  Given a socket, attempts to navigate to a `:redirect_to` assign, otherwise
  navigates to the `:return_to` assign.
  """
  @spec redirect_or_return(Phoenix.LiveView.Socket.t()) ::
          Phoenix.LiveView.Socket.t()
  def redirect_or_return(socket) do
    case socket.assigns.redirect_to do
      nil ->
        LiveView.push_redirect(socket, to: socket.assigns.return_to)

      redirect_to ->
        LiveView.push_redirect(socket, to: redirect_to)
    end
  end
end
