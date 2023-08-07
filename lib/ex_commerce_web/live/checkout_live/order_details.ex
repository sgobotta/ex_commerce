defmodule ExCommerceWeb.CheckoutLive.OrderDetails do
  @moduledoc """
  Live Checkout: order details section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, :live_checkout}
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
      |> assign(:container_class, "container-base full")
      |> assign(:cart_enabled, true)
      |> assign(:cart_visible, true)
      |> assign(:brand_slug, params["brand"])
      |> assign(:shop_slug, params["shop"])
    }
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    {:noreply, assign_changeset(socket, order_params)}
  end

  def handle_event("ignore", _params, socket), do: {:noreply, socket}

  def handle_event(
        "select_payment_method",
        %{"type" => payment_method_type},
        socket
      ) do
    {:noreply,
     assign_changeset(socket, %{
       "payment_method" => %{"type" => payment_method_type}
     })}
  end

  def handle_event("submit_details", _params, socket) do
    %{
      brand_slug: brand_slug,
      cart: %Cart{} = cart,
      catalogue: catalogue,
      shop_slug: shop_slug
    } = socket.assigns

    socket
    |> assign_cart(Checkout.set_order_price(cart))
    |> LiveView.redirect(
      to:
        Routes.checkout_order_path(
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
    |> assign(:page_title, gettext("[Cart]"))
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

    %Ecto.Changeset{} = changeset = Checkout.change_order_details(order, params)

    %Cart{} = cart = Checkout.update_cart_order(cart, changeset)

    socket
    |> assign(:changeset, changeset)
    |> assign_cart(cart)
  end

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp assign_cart(socket, %Cart{} = cart), do: assign(socket, :cart, cart)

  defp assign_cart_path(socket, brand_slug, shop_slug, catalogue_id) do
    cart_path =
      Routes.checkout_order_details_path(
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

  defp valid_checkout?(%Ecto.Changeset{valid?: false}, %Cart{}), do: false

  defp valid_checkout?(%Ecto.Changeset{valid?: true}, %Cart{} = cart),
    do: Checkout.valid_checkout?(cart)

  defp get_button_text(%Ecto.Changeset{valid?: valid?}, %Cart{} = cart) do
    case Checkout.valid_checkout?(cart) do
      true ->
        if valid?,
          do: gettext("Continue"),
          else: gettext("Complete the missing fields")

      false ->
        gettext("Add products to your order")
    end
  end

  defp get_order_items(%Cart{} = cart), do: Checkout.get_order_items(cart)

  defp get_order_price(%Cart{} = cart), do: "$#{Checkout.get_order_price(cart)}"

  # No db data or user input is present for catalogue item id
  defp get_payment_methods do
    [
      {gettext("Cash"), :cash},
      {gettext("Mercadopago"), :mercadopago}
    ]
  end

  defp payment_checked?(changeset, payment_method_id) do
    payment_method = Ecto.Changeset.get_field(changeset, :payment_method)

    payment_method_type =
      if payment_method do
        payment_method.type
      else
        nil
      end

    payment_method_type == payment_method_id
  end
end
