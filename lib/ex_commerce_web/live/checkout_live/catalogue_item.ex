defmodule ExCommerceWeb.CheckoutLive.CatalogueItem do
  @moduledoc """
  Live Checkout: catalogue item section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_checkout.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign_public_defaults(params, session)
      |> assign_shop_by_slug_or_redirect(params)
      |> assign(:brand_slug, params["brand"])
      |> assign(:shop_slug, params["shop"])
      |> assign(:quantity, 1)
    }
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_event(
        "remove_item",
        _params,
        %{assigns: %{quantity: 1 = quantity}} = socket
      ),
      do: {:noreply, assign(socket, :quantity, quantity)}

  def handle_event(
        "remove_item",
        _params,
        %{assigns: %{quantity: quantity}} = socket
      ),
      do: {:noreply, assign(socket, :quantity, quantity - 1)}

  def handle_event(
        "add_item",
        _params,
        %{assigns: %{quantity: quantity}} = socket
      ),
      do: {:noreply, assign(socket, :quantity, quantity + 1)}

  defp apply_action(socket, :index, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id,
         "item" => catalogue_item_id
       }) do
    socket
    |> assign(:page_title, gettext("[Catalogue Item Name]"))
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
    |> assign_catalogue_item(catalogue_item_id)
    |> assign_photos_sources()
    |> assign_nav_title()
  end

  defp assign_photos_sources(
         %{assigns: %{catalogue_item: %CatalogueItem{photos: photos}}} = socket
       ) do
    item_photo_source =
      get_photos(photos,
        use_placeholder: true,
        type: :avatar
      )
      |> Enum.map(&get_photo_source(socket, &1))
      |> hd()

    socket
    |> assign(:item_photo_source, item_photo_source)
  end

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp assign_catalogue_item(socket, catalogue_item_id),
    do: assign_catalogue_item_by_id_or_redirect(socket, catalogue_item_id)

  defp assign_nav_title(socket) do
    socket
    |> assign(:nav_title, gettext("Back"))
  end

  defp get_price(price) do
    price
    |> ExCommerceNumeric.format_price()
    |> prepend_currency()
  end

  defp prepend_currency(price), do: "$#{price}"
end
