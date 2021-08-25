defmodule ExCommerceWeb.ShopLive.Index do
  @moduledoc false

  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Shop

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :shops, list_shops())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Shop")
    |> assign(:shop, Marketplaces.get_shop!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Shop")
    |> assign(:shop, %Shop{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Shops")
    |> assign(:shop, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    shop = Marketplaces.get_shop!(id)
    {:ok, _} = Marketplaces.delete_shop(shop)

    {:noreply, assign(socket, :shops, list_shops())}
  end

  defp list_shops do
    Marketplaces.list_shops()
  end
end
