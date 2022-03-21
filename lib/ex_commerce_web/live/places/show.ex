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

  @impl true
  def mount(params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(params, session)
     |> assign_place_by_slug_or_redirect(params)
     |> assign_photos_sources()
     |> assign(:brand_slug, params["brand"])
     |> assign(:shop_slug, params["shop"])}

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

  defp apply_action(socket, :show, %{"brand" => brand_slug}) do
    socket
    |> assign(:page_title, gettext("[Shop Name]"))
    |> assign(:return_to, Routes.place_index_path(socket, :index, brand_slug))
  end

  defp apply_action(socket, :show_catalogue, %{
         "brand" => brand_slug,
         "shop" => shop_slug
       }) do
    socket
    |> assign(:page_title, gettext("[Catalogue Name]"))
    |> assign(
      :return_to,
      Routes.place_show_path(socket, :show, brand_slug, shop_slug)
    )
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
end
