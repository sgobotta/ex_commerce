defmodule ExCommerceWeb.CheckoutLive.Shop do
  @moduledoc """
  Live Checkout: shop section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_checkout.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Marketplaces.Shop

  alias ExCommerce.Offerings.Catalogue

  @impl true
  def mount(params, session, socket) do
    {:ok,
     socket
     |> assign_public_defaults(params, session)
     |> assign_shop_by_slug_or_redirect(params)
     |> assign(:cart_visible, false)
     |> assign(:brand_slug, params["brand"])
     |> assign(:shop_slug, params["shop"])}
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  defp apply_action(socket, :index, %{"brand" => brand_slug}) do
    socket
    |> assign(:page_title, gettext("[Shop Name]"))
    |> assign(:return_to, Routes.place_index_path(socket, :index, brand_slug))
    |> assign_photos_sources()
    |> assign_nav_title()
  end

  defp assign_photos_sources(
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

  defp assign_nav_title(socket) do
    socket
    |> assign(:nav_title, gettext("Back"))
  end
end
