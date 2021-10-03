defmodule ExCommerceWeb.CatalogueItemLive.Index do
  use ExCommerceWeb, :live_view

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItem

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :catalogue_items, list_catalogue_items())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Catalogue item")
    |> assign(:catalogue_item, Offerings.get_catalogue_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Catalogue item")
    |> assign(:catalogue_item, %CatalogueItem{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Catalogue items")
    |> assign(:catalogue_item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    catalogue_item = Offerings.get_catalogue_item!(id)
    {:ok, _} = Offerings.delete_catalogue_item(catalogue_item)

    {:noreply, assign(socket, :catalogue_items, list_catalogue_items())}
  end

  defp list_catalogue_items do
    Offerings.list_catalogue_items()
  end
end
