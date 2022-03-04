defmodule ExCommerceWeb.CatalogueItemOptionGroupLive.Index do
  @moduledoc """
  Lists available catalogue item option groups
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_main_dashboard.html"}
  }

  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItemOptionGroup
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
          %{
            assigns: %{
              brand: %Brand{
                catalogue_item_option_groups: catalogue_item_option_groups
              }
            }
          } = socket

          socket
          |> assign(:catalogue_item_option_groups, catalogue_item_option_groups)
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
       gettext(
         "Please Manage a brand to continue browsing catalogue item option groups"
       )
     )
     |> redirect(to: Routes.brand_index_path(socket, :index))}
  end

  defp apply_action(
         socket,
         :edit,
         %{
           "catalogue_item_option_group_id" => _catalogue_item__option_group_id
         } = params
       ) do
    socket
    |> assign(:page_title, gettext("Edit Catalogue item option group"))
    |> assign_catalogue_item_option_group_or_redirect(params, %{})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Catalogue item option group"))
    |> assign(
      :catalogue_item_option_group,
      prepare_catalogue_item_option_group(socket.assigns)
    )
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Catalogue item option groups"))
    |> assign(:catalogue_item_option_group, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => catalogue_item_option_group_id}, socket) do
    catalogue_item_option_group =
      Offerings.get_catalogue_item_option_group!(catalogue_item_option_group_id)

    {:ok, _} =
      Offerings.delete_catalogue_item_option_group(catalogue_item_option_group)

    {:noreply, update_catalogue_item_option_groups(socket)}
  end

  defp prepare_catalogue_item_option_group(%{brand: %Brand{id: brand_id}}) do
    %CatalogueItemOptionGroup{brand_id: brand_id}
    |> Repo.preload([:options, :items])
  end

  defp update_catalogue_item_option_groups(
         %{assigns: %{brand: %Brand{} = brand}} = socket
       ) do
    %{catalogue_item_option_groups: catalogue_item_option_groups} =
      brand = Repo.preload(brand, [:catalogue_item_option_groups], force: true)

    socket
    |> assign(:brand, brand)
    |> assign(:catalogue_item_option_groups, catalogue_item_option_groups)
  end
end
