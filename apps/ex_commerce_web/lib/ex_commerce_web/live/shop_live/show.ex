defmodule ExCommerceWeb.ShopLive.Show do
  @moduledoc false

  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:shop, Marketplaces.get_shop!(id))}
  end

  defp page_title(:show), do: "Show Shop"
  defp page_title(:edit), do: "Edit Shop"
end
