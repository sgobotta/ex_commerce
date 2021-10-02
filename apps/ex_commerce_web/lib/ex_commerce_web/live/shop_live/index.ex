defmodule ExCommerceWeb.ShopLive.Index do
  @moduledoc """
  Lists available shops
  """

  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Marketplaces.Shop

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brand(params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"brand_id" => _brand_id} = params, _url, socket) do
    socket =
      case connected?(socket) do
        true ->
          %{assigns: %{brand: %Brand{shops: shops}}} = socket

          socket
          |> assign(:shops, shops)
          |> apply_action(socket.assigns.live_action, params)

        false ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext("Please Manage a brand to continue browsing shops")
     )
     |> apply_action(socket.assigns.live_action, params)
     |> redirect(to: Routes.brand_index_path(socket, :index))}
  end

  defp apply_action(socket, :edit, %{"shop_id" => shop_id}) do
    %{assigns: %{shops: shops}} = socket

    case Enum.find(shops, nil, &(&1.id == shop_id)) do
      nil ->
        %{assigns: %{brand: %Brand{id: brand_id}}} = socket

        socket
        |> put_flash(:error, gettext("The given shop could not be found"))
        |> redirect(to: Routes.shop_index_path(socket, :index, brand_id))

      %Shop{} = shop ->
        socket
        |> assign(:page_title, gettext("Edit Shop"))
        |> assign(:shop, shop)
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Shop"))
    |> assign(:shop, prepare_new_shop(socket.assigns))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Shops"))
    |> assign(:shop, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => shop_id}, socket) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    %Shop{} = shop = Marketplaces.get_shop!(shop_id)
    {:ok, _} = Marketplaces.delete_shop(shop)

    {:noreply, assign(socket, :shops, list_shops(brand_id))}
  end

  defp prepare_new_shop(%{brand: %Brand{id: brand_id}}) do
    %Shop{brand_id: brand_id}
  end

  defp list_shops(brand_id) do
    Marketplaces.list_shops_by_brand(brand_id)
  end
end
