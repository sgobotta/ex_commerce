defmodule ExCommerceWeb.CatalogueItemLive.Show do
  use ExCommerceWeb, :live_view

  alias ExCommerce.Offerings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:catalogue_item, Offerings.get_catalogue_item!(id))}
  end

  defp page_title(:show), do: "Show Catalogue item"
  defp page_title(:edit), do: "Edit Catalogue item"
end
