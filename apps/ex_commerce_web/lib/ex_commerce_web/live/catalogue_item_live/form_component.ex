defmodule ExCommerceWeb.CatalogueItemLive.FormComponent do
  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings

  @impl true
  def update(%{catalogue_item: catalogue_item} = assigns, socket) do
    changeset = Offerings.change_catalogue_item(catalogue_item)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"catalogue_item" => catalogue_item_params}, socket) do
    changeset =
      socket.assigns.catalogue_item
      |> Offerings.change_catalogue_item(catalogue_item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"catalogue_item" => catalogue_item_params}, socket) do
    save_catalogue_item(socket, socket.assigns.action, catalogue_item_params)
  end

  defp save_catalogue_item(socket, :edit, catalogue_item_params) do
    case Offerings.update_catalogue_item(socket.assigns.catalogue_item, catalogue_item_params) do
      {:ok, _catalogue_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Catalogue item updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue_item(socket, :new, catalogue_item_params) do
    case Offerings.create_catalogue_item(catalogue_item_params) do
      {:ok, _catalogue_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Catalogue item created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
