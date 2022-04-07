defmodule ExCommerceWeb.PlaceLive.Show do
  @moduledoc """
  Shows a single places
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_places.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Marketplaces.Shop

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueCategory,
    CatalogueItem,
    # CatalogueItemOption,
    CatalogueItemVariant
  }

  @impl true
  def mount(params, session, socket) do
    {:ok,
     socket
     |> assign_public_defaults(params, session)
     |> assign_place_by_slug_or_redirect(params)
     |> assign(:brand_slug, params["brand"])
     |> assign(:shop_slug, params["shop"])
     |> assign(:quantity, 1)}

    # case connected?(socket) do
    #   true ->

    #   false ->
    #     {:ok, socket}
    # end
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  # defp apply_action_maybe(socket, live_action, params) do
  #   case connected?(socket) do
  #     true ->
  #       apply_action(socket, live_action, params)

  #     false ->
  #       socket
  #   end
  # end

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

  defp apply_action(socket, :show, %{"brand" => brand_slug}) do
    socket
    |> assign(:page_title, gettext("[Shop Name]"))
    |> assign(:return_to, Routes.place_index_path(socket, :index, brand_slug))
    |> assign_shop_photos_sources()
    |> assign_nav_title()
  end

  defp apply_action(socket, :show_catalogue, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id
       }) do
    socket
    |> assign(:page_title, gettext("[Catalogue Name]"))
    |> assign(
      :return_to,
      Routes.place_show_path(socket, :show, brand_slug, shop_slug)
    )
    |> assign_catalogue(catalogue_id)
    |> assign_nav_title()
  end

  defp apply_action(socket, :show_item, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id,
         "item" => catalogue_item_id
       }) do
    socket
    |> assign(:page_title, gettext("[Item Name]"))
    |> assign(
      :return_to,
      Routes.place_show_path(
        socket,
        :show_catalogue,
        brand_slug,
        shop_slug,
        catalogue_id
      )
    )
    |> assign_catalogue(catalogue_id)
    |> assign_catalogue_item(catalogue_item_id)
    |> assign_item_photos_sources()
    |> assign_nav_title()
  end

  defp assign_shop_photos_sources(
         %{assigns: %{shop: %Shop{avatars: avatars, banners: banners}}} = socket
       ) do
    avatar_source =
      get_photos(avatars,
        use_placeholder: true,
        type: :avatar
      )
      |> Enum.map(&get_photo_source(socket, &1))
      |> hd()

    banner_source =
      get_photos(banners,
        use_placeholder: true,
        type: :banner
      )
      |> Enum.map(&get_photo_source(socket, &1))
      |> hd()

    socket
    |> assign(:avatar_source, avatar_source)
    |> assign(:banner_source, banner_source)
  end

  defp assign_item_photos_sources(
         %{assigns: %{catalogue_item: %CatalogueItem{photos: photos}}} = socket
       ) do
    avatar_source =
      get_photos(photos,
        use_placeholder: true,
        type: :avatar
      )
      |> Enum.map(&get_photo_source(socket, &1))
      |> hd()

    banner_source =
      get_photos([],
        use_placeholder: true,
        type: :banner
      )
      |> Enum.map(&get_photo_source(socket, &1))
      |> hd()

    socket
    |> assign(:avatar_source, avatar_source)
    |> assign(:banner_source, banner_source)
  end

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp assign_catalogue_item(socket, catalogue_id),
    do: assign_catalogue_item_by_id_or_redirect(socket, catalogue_id)

  defp assign_nav_title(socket) do
    title =
      case socket.assigns.live_action do
        :show ->
          gettext("Back")

        :show_catalogue ->
          socket.assigns.shop.name

        :show_item ->
          socket.assigns.catalogue_item.name
      end

    socket
    |> assign(:nav_title, title)
  end

  defp get_item_price([]), do: gettext("Price not available")

  defp get_item_price(variants) do
    Offerings.get_cheapest_variant_price(variants)
    |> ExCommerceNumeric.format_price()
    |> prepend_currency()
  end

  defp prepend_currency(price), do: "$#{price}"
end
