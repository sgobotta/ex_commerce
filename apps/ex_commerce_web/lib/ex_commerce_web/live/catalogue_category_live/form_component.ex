defmodule ExCommerceWeb.CatalogueCategoryLive.FormComponent do
  @moduledoc """
  Form for catalogue categories create/edit actions
  """
  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.{CatalogueCategory, CatalogueItem}

  import ExCommerceWeb.LiveFormHelpers

  @impl true
  def update(
        %{catalogue_category: %CatalogueCategory{} = catalogue_category} =
          assigns,
        socket
      ) do
    changeset = Offerings.change_catalogue_category(catalogue_category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"catalogue_category" => catalogue_category_params},
        socket
      ) do
    %Ecto.Changeset{data: %CatalogueCategory{brand_id: brand_id}} =
      socket.assigns.changeset

    changeset =
      socket.assigns.catalogue_category
      |> Offerings.change_catalogue_category(
        catalogue_category_params
        |> assign_brand_id_param(brand_id)
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "save",
        %{"catalogue_category" => catalogue_category_params},
        socket
      ) do
    save_catalogue_category(
      socket,
      socket.assigns.action,
      catalogue_category_params
    )
  end

  def handle_event("create_item", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(
       to:
         Routes.catalogue_item_index_path(
           socket,
           :new,
           socket.assigns.catalogue_category.brand_id,
           redirect_to: socket.assigns.current_route
         )
     )}
  end

  # ----------------------------------------------------------------------------
  # Private helpers
  #

  defp save_catalogue_category(socket, :edit, catalogue_category_params) do
    case Offerings.update_catalogue_category(
           socket.assigns.catalogue_category,
           catalogue_category_params
         ) do
      {:ok, %CatalogueCategory{} = _catalogue_category} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue category updated successfully"))
         |> redirect_or_return()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue_category(socket, :new, catalogue_category_params) do
    %{assigns: %{catalogue_category: %CatalogueCategory{brand_id: brand_id}}} =
      socket

    catalogue_category_params =
      assign_brand_id_param(catalogue_category_params, brand_id)

    case Offerings.create_catalogue_category(catalogue_category_params) do
      {:ok, %CatalogueCategory{} = _catalogue_category} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue category created successfully"))
         |> redirect_or_return()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # ----------------------------------------------------------------------------
  # Catalogue item categories selection helpers
  #

  defp get_selected_catalogue_items(%Phoenix.HTML.Form{
         source: %Ecto.Changeset{
           changes: %{
             items: items
           }
         }
       }) do
    Enum.map(items, fn %Ecto.Changeset{
                         data: %CatalogueItem{id: id}
                       } ->
      id
    end)
  end

  defp get_selected_catalogue_items(%Phoenix.HTML.Form{}), do: []

  defp build_catalogue_item_options(catalogue_items) do
    Enum.map(catalogue_items, fn %CatalogueItem{
                                   id: id,
                                   code: code
                                 } ->
      {code, id}
    end)
  end
end
