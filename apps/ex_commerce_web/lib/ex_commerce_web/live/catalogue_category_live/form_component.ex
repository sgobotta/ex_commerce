defmodule ExCommerceWeb.CatalogueCategoryLive.FormComponent do
  @moduledoc """
  Form for catalogue categories create/edit actions
  """
  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueCategory

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
    changeset =
      socket.assigns.catalogue_category
      |> Offerings.change_catalogue_category(catalogue_category_params)
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

  defp save_catalogue_category(socket, :edit, catalogue_category_params) do
    case Offerings.update_catalogue_category(
           socket.assigns.catalogue_category,
           catalogue_category_params
         ) do
      {:ok, %CatalogueCategory{} = _catalogue_category} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue category updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue_category(socket, :new, catalogue_category_params) do
    %{assigns: %{catalogue_category: %CatalogueCategory{brand_id: brand_id}}} =
      socket

    catalogue_category_params =
      Map.merge(catalogue_category_params, %{"brand_id" => brand_id})

    case Offerings.create_catalogue_category(catalogue_category_params) do
      {:ok, _catalogue_category} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue category created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
