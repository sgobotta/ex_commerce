defmodule ExCommerceWeb.BrandLive.Index do
  @moduledoc """
  Lists available brands
  """
  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :brands, list_brands())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Brand")
    |> assign(:brand, Marketplaces.get_brand!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Brand")
    |> assign(:brand, %Brand{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Brands")
    |> assign(:brand, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    brand = Marketplaces.get_brand!(id)
    {:ok, _} = Marketplaces.delete_brand(brand)

    {:noreply, assign(socket, :brands, list_brands())}
  end

  defp list_brands do
    Marketplaces.list_brands()
  end
end
