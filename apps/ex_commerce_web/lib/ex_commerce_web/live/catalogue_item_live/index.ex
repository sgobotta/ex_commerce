defmodule ExCommerceWeb.CatalogueItemLive.Index do
  @moduledoc """
  Lists available catalogue items
  """

  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItem
  alias ExCommerce.Repo

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brand_or_redirect(params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"brand_id" => _brand_id} = params, _url, socket) do
    socket =
      case connected?(socket) do
        true ->
          %{assigns: %{brand: %Brand{catalogue_items: catalogue_items}}} =
            socket

          socket
          |> assign(:catalogue_items, catalogue_items)
          |> apply_action(socket.assigns.live_action, params)

        false ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext("Please Manage a brand to continue browsing catalogue items")
     )
     |> redirect(to: Routes.brand_index_path(socket, :index))}
  end

  defp apply_action(
         socket,
         :edit,
         %{"catalogue_item_id" => _catalogue_item_id} = params
       ) do
    socket
    |> assign(:page_title, gettext("Edit Catalogue item"))
    |> assign_catalogue_item_or_redirect(params, %{})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Catalogue item"))
    |> assign(:catalogue_item, prepare_catalogue_item(socket.assigns))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Catalogue items"))
    |> assign(:catalogue_item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => catalogue_item_id}, socket) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    %CatalogueItem{} =
      catalogue_item = Offerings.get_catalogue_item!(catalogue_item_id)

    {:ok, _} = Offerings.delete_catalogue_item(catalogue_item)

    {:noreply, assign(socket, :catalogue_items, list_catalogue_items(brand_id))}
  end

  defp prepare_catalogue_item(%{brand: %Brand{id: brand_id}}) do
    %CatalogueItem{brand_id: brand_id}
    |> Repo.preload([:variants])
  end

  defp list_catalogue_items(brand_id) do
    Offerings.list_catalogue_items_by_brand(brand_id)
  end
end
