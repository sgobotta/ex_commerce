defmodule ExCommerceWeb.ShopLive.Show do
  @moduledoc """
  Shows a single shop
  """

  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Marketplaces.Shop

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brand(params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => shop_id}, _url, socket) do
    case connected?(socket) do
      true ->
        %{assigns: %{brand: %Brand{shops: shops}}} = socket

        case Enum.find(shops, nil, &(&1.id == shop_id)) do
          nil ->
            %{assigns: %{brand: %Brand{id: brand_id}}} = socket

            {:noreply,
             socket
             |> redirect(to: Routes.shop_index_path(socket, :index, brand_id))}

          %Shop{} = shop ->
            {:noreply,
             socket
             |> assign(:page_title, page_title(socket.assigns.live_action))
             |> assign(:shop, shop)}
        end

      false ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: gettext("Show Shop")
  defp page_title(:edit), do: gettext("Edit Shop")
end
