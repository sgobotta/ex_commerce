defmodule ExCommerceWeb.CatalogueLive.FormComponent do
  @moduledoc """
  Form for catalogues create/edit actions
  """

  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.{Catalogue, CatalogueCategory}

  import ExCommerceWeb.LiveFormHelpers

  @impl true
  def update(%{catalogue: %Catalogue{} = catalogue} = assigns, socket) do
    changeset = Offerings.change_catalogue(catalogue)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"catalogue" => catalogue_params}, socket) do
    %Ecto.Changeset{data: %Catalogue{brand_id: brand_id}} =
      socket.assigns.changeset

    changeset =
      socket.assigns.catalogue
      |> Offerings.change_catalogue(
        catalogue_params
        |> assign_brand_id_param(brand_id)
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"catalogue" => catalogue_params}, socket) do
    save_catalogue(socket, socket.assigns.action, catalogue_params)
  end

  def handle_event("create_category", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(
       to:
         Routes.catalogue_category_index_path(
           socket,
           :new,
           socket.assigns.catalogue.brand_id,
           redirect_to: socket.assigns.current_route
         )
     )}
  end

  # ----------------------------------------------------------------------------
  # Private helpers
  #

  defp save_catalogue(socket, :edit, catalogue_params) do
    case Offerings.update_catalogue(
           socket.assigns.catalogue,
           catalogue_params
         ) do
      {:ok, %Catalogue{} = _catalogue} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue updated successfully"))
         |> redirect_or_return()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue(socket, :new, catalogue_params) do
    %{assigns: %{catalogue: %Catalogue{brand_id: brand_id}}} = socket

    catalogue_params = assign_brand_id_param(catalogue_params, brand_id)

    case Offerings.create_catalogue(catalogue_params) do
      {:ok, %Catalogue{} = _catalogue} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue created successfully"))
         |> redirect_or_return()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # ----------------------------------------------------------------------------
  # Catalogue categories selection helpers
  #

  defp get_selected_catalogue_categories(%Phoenix.HTML.Form{
         source: %Ecto.Changeset{
           changes: %{
             categories: categories
           }
         }
       }) do
    Enum.map(categories, fn %Ecto.Changeset{
                              data: %CatalogueCategory{id: id}
                            } ->
      id
    end)
  end

  defp get_selected_catalogue_categories(%Phoenix.HTML.Form{}), do: []

  defp build_catalogue_category_options(catalogue_categories) do
    Enum.map(catalogue_categories, fn %CatalogueCategory{
                                        id: id,
                                        code: code
                                      } ->
      {code, id}
    end)
  end
end
