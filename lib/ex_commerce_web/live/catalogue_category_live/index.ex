defmodule ExCommerceWeb.CatalogueCategoryLive.Index do
  @moduledoc """
  Lists available catalogue categories
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_main_dashboard.html"}
  }

  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueCategory
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
  def handle_params(
        %{"brand_id" => _brand_id} = params,
        _url,
        socket
      ) do
    socket =
      case connected?(socket) do
        true ->
          %{
            assigns: %{
              brand: %Brand{catalogue_categories: catalogue_categories}
            }
          } = socket

          socket
          |> assign(:catalogue_categories, catalogue_categories)
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
       :warn,
       gettext(
         "Please select a brand to continue browsing catalogue categories"
       )
     )
     |> redirect(to: Routes.brand_index_path(socket, :index))}
  end

  defp apply_action(
         socket,
         :edit,
         %{"catalogue_category_id" => _catalogue_category_id} = params
       ) do
    socket
    |> assign(:page_title, gettext("Edit Catalogue category"))
    |> assign_catalogue_category_or_redirect(params, %{})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Catalogue category"))
    |> assign(
      :catalogue_category,
      prepare_new_catalogue_category(socket.assigns)
    )
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Catalogue categories"))
    |> assign(:catalogue_category, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => catalogue_category_id}, socket) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    %CatalogueCategory{} =
      catalogue_category =
      Offerings.get_catalogue_category!(catalogue_category_id)

    {:ok, _} = Offerings.delete_catalogue_category(catalogue_category)

    {:noreply,
     assign(socket, :catalogue_categories, list_catalogue_categories(brand_id))}
  end

  defp prepare_new_catalogue_category(%{brand: %Brand{id: brand_id}}) do
    %CatalogueCategory{brand_id: brand_id}
    |> Repo.preload([:items, :catalogues])
  end

  defp list_catalogue_categories(brand_id) do
    Offerings.list_catalogue_categories_by_brand(brand_id)
  end
end
