defmodule ExCommerceWeb.CheckoutLive.Catalogue do
  @moduledoc """
  Live Checkout: catalogue section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_checkout.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueCategory,
    CatalogueItem
  }

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign_public_defaults(params, session)
      |> assign_shop_by_slug_or_redirect(params)
      |> assign(:cart_visible, true)
      |> assign(:brand_slug, params["brand"])
      |> assign(:shop_slug, params["shop"])
    }
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  defp apply_action(socket, :index, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id
       }) do
    socket
    |> assign(:page_title, gettext("[Catalogue Name]"))
    |> assign(
      :return_to,
      Routes.checkout_shop_path(socket, :index, brand_slug, shop_slug)
    )
    |> assign_catalogue(catalogue_id)
    |> assign_nav_title()
  end

  @impl true
  def handle_event("checkout_order", _params, socket) do
    {:noreply, socket}
  end

  defp valid_order? do
    true
  end

  defp get_order_items(items) do
    items
  end

  defp get_order_price(price) do
    "$#{price}"
  end

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp assign_nav_title(socket) do
    socket
    |> assign(:nav_title, gettext("Back"))
  end

  defp get_item_price([]), do: gettext("Price not available")

  defp get_item_price(variants) do
    Offerings.get_cheapest_variant_price(variants)
    |> ExCommerceNumeric.format_price()
    |> prepend_currency()
  end

  defp prepend_currency(price), do: "$#{price}"

  defp get_item_route(
         socket,
         brand_slug,
         shop_slug,
         %Catalogue{id: catalogue_id},
         item_id
       ) do
    Routes.checkout_catalogue_item_path(
      socket,
      :index,
      brand_slug,
      shop_slug,
      catalogue_id,
      item_id
    )
  end
end
