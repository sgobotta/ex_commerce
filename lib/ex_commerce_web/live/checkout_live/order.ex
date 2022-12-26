defmodule ExCommerceWeb.CheckoutLive.Order do
  @moduledoc """
  Live Checkout: complete order section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_checkout.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.Cart

  alias ExCommerce.Marketplaces.Shop

  alias ExCommerce.Offerings.Catalogue

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
      |> assign_href(false)
    }
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_event("confirm_order", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "remove_order_item",
        %{"remove" => order_item_temp_id},
        socket
      ) do
    %{cart: %Cart{} = cart} = socket.assigns

    case Checkout.remove_order_item(cart, order_item_temp_id) do
      %Cart{order: %Cart.Order{order_items: []}} = cart ->
        %{
          brand_slug: brand_slug,
          shop_slug: shop_slug,
          catalogue: %Catalogue{id: catalogue_id}
        } = socket.assigns

        LiveView.redirect(assign_cart(socket, cart),
          to:
            Routes.checkout_catalogue_path(
              socket,
              :index,
              brand_slug,
              shop_slug,
              catalogue_id
            )
        )

      %Cart{order: %Cart.Order{order_items: _order_items}} = cart ->
        assign_cart(socket, cart)
    end
    |> then(fn socket -> {:noreply, socket} end)
  end

  defp apply_action(socket, :new, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id
       }) do
    socket
    |> assign(:page_title, gettext("Confirm Order"))
    |> assign(
      :return_to,
      Routes.checkout_order_details_path(
        socket,
        :new,
        brand_slug,
        shop_slug,
        catalogue_id
      )
    )
    |> assign_catalogue(catalogue_id)
    |> assign_changeset()
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
    |> assign(:page_title, gettext("Cart"))
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
    |> assign_changeset()
    |> assign(:cart_path, "#")
    |> assign_nav_title()
  end

  defp assign_changeset(socket, params \\ %{}) do
    %{
      cart: %Cart{order: %Cart.Order{} = order} = cart,
      catalogue: %Catalogue{id: catalogue_id},
      shop: %Shop{id: shop_id, brand_id: brand_id}
    } = socket.assigns

    params =
      %{
        "brand_id" => brand_id,
        "catalogue_id" => catalogue_id,
        "shop_id" => shop_id
      }
      |> Map.merge(params)

    %Ecto.Changeset{valid?: valid?} =
      changeset = Checkout.change_order_details(order, params)

    %Cart{} = cart = Checkout.update_cart_order(cart, changeset)

    socket
    |> assign(:changeset, changeset)
    |> assign_cart(cart)
    |> assign_href(valid?)
  end

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp assign_cart(socket, %Cart{} = cart), do: assign(socket, :cart, cart)

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

  def assign_href(socket, true) do
    %{
      cart: %Cart{} = cart,
      shop: %Shop{telephone: telephone}
    } = socket.assigns

    message = Checkout.get_order_message(cart)

    telephone = String.replace(telephone, " ", "")

    url =
      "https://web.whatsapp.com/send/?phone=#{telephone}&text=#{message}&type=phone_number&app_absent=0"

    assign(socket, :href, url)
  end

  def assign_href(socket, false) do
    assign(socket, :href, nil)
  end

  defp assign_nav_title(socket) do
    socket
    |> assign(:nav_title, gettext("Back"))
  end

  defp valid_checkout?(%Ecto.Changeset{valid?: false}, %Cart{}), do: false

  defp valid_checkout?(%Ecto.Changeset{valid?: true}, %Cart{} = cart),
    do: Checkout.valid_checkout?(cart)

  defp get_button_text(%Ecto.Changeset{valid?: valid?}, %Cart{} = cart) do
    case Checkout.valid_checkout?(cart) do
      true ->
        if valid?,
          do: gettext("Confirm"),
          else: gettext("Complete the missing fields")

      false ->
        gettext("Add products to your order")
    end
  end

  defp get_order_items(%Cart{} = cart), do: Checkout.get_order_items(cart)

  defp get_order_price(%Cart{} = cart), do: "$#{Checkout.get_order_price(cart)}"
end
