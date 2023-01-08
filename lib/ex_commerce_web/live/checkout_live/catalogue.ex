defmodule ExCommerceWeb.CheckoutLive.Catalogue do
  @moduledoc """
  Live Checkout: catalogue section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_checkout.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.Cart

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueCategory,
    CatalogueItem
  }

  alias ExCommerceWeb.CheckoutLive.Components

  alias Phoenix.LiveView

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

  @impl true
  def handle_event("checkout_order", _params, socket) do
    %{
      brand_slug: brand_slug,
      cart: %Cart{} = cart,
      catalogue: catalogue,
      shop_slug: shop_slug
    } = socket.assigns

    socket = assign_cart(socket, cart)

    LiveView.redirect(socket,
      to:
        Routes.checkout_order_details_path(
          socket,
          :new,
          brand_slug,
          shop_slug,
          catalogue
        )
    )
    |> then(fn socket -> {:noreply, socket} end)
  end

  def handle_event(
        "remove_order_item",
        %{"remove" => order_item_temp_id},
        socket
      ) do
    %{cart: %Cart{} = cart} = socket.assigns

    case Checkout.remove_order_item(cart, order_item_temp_id) do
      %Cart{order: %Cart.Order{order_items: []}} = cart ->
        LiveView.push_patch(assign_cart(socket, cart),
          to: socket.assigns.return_to
        )

      %Cart{order: %Cart.Order{order_items: _order_items}} = cart ->
        assign_cart(socket, cart)
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

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
    |> assign_cart_path(brand_slug, shop_slug, catalogue_id)
    |> assign_nav_title()
  end

  defp apply_action(
         socket,
         :cart,
         %{
           "brand" => brand_slug,
           "shop" => shop_slug,
           "catalogue" => catalogue_id
         }
       ) do
    socket
    |> assign(:page_title, gettext("[Cart]"))
    |> assign(
      :return_to,
      Routes.checkout_catalogue_path(
        socket,
        :index,
        brand_slug,
        shop_slug,
        catalogue_id
      )
    )
    |> assign_catalogue(catalogue_id)
    |> assign(:cart_path, "#")
    |> assign_nav_title()
  end

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp assign_cart_path(socket, brand_slug, shop_slug, catalogue_id) do
    cart_path =
      Routes.checkout_catalogue_path(
        socket,
        :cart,
        brand_slug,
        shop_slug,
        catalogue_id
      )

    assign(socket, :cart_path, cart_path)
  end

  defp assign_nav_title(socket) do
    socket
    |> assign(:nav_title, gettext("Back"))
  end

  defp assign_cart(socket, %Cart{} = cart), do: assign(socket, :cart, cart)

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

  defp valid_checkout?(%Cart{} = cart), do: Checkout.valid_checkout?(cart)

  defp get_order_items(%Cart{} = cart), do: Checkout.get_order_items(cart)

  defp get_order_price(%Cart{} = cart), do: "$#{Checkout.get_order_price(cart)}"
end
