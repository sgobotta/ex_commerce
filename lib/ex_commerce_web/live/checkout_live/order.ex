defmodule ExCommerceWeb.CheckoutLive.Order do
  @moduledoc """
  Live Checkout: order section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_checkout.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.{Cart, Order}

  alias ExCommerceWeb.CheckoutLive.Components

  @impl true
  def mount(params, session, socket) do
    %{assigns: %{cart: %Cart{order: %Order{} = order}}} = socket

    {
      :ok,
      socket
      |> assign_public_defaults(params, session)
      |> assign_shop_by_slug_or_redirect(params)
      |> assign(:cart_visible, true)
      |> assign(:brand_slug, params["brand"])
      |> assign(:shop_slug, params["shop"])
      |> assign(:changeset, Checkout.change_order(order))
    }
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("complete_order", _params, socket) do
    {:noreply, socket}
  end

  defp apply_action(socket, :new, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id
       }) do
    socket
    |> assign(:page_title, gettext("[Create Order]"))
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
      Routes.checkout_order_path(
        socket,
        :new,
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
      Routes.checkout_order_path(
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

  defp valid_checkout?(%Cart{} = cart), do: Checkout.valid_checkout?(cart)

  defp get_order_items(%Cart{} = cart), do: Checkout.get_order_items(cart)

  defp get_order_price(%Cart{} = cart), do: "$#{Checkout.get_order_price(cart)}"
end
