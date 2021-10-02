defmodule ExCommerceWeb.BrandLive.FormComponent do
  @moduledoc """
  Form for brands create/edit actions
  """
  use ExCommerceWeb, :live_component

  alias ExCommerce.Marketplaces

  @impl true
  def update(%{brand: brand} = assigns, socket) do
    changeset = Marketplaces.change_brand(brand)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"brand" => brand_params}, socket) do
    changeset =
      socket.assigns.brand
      |> Marketplaces.change_brand(brand_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"brand" => brand_params}, socket) do
    save_brand(socket, socket.assigns.action, brand_params)
  end

  defp save_brand(socket, :edit, brand_params) do
    case Marketplaces.update_brand(socket.assigns.brand, brand_params) do
      {:ok, _brand} ->
        {:noreply,
         socket
         |> put_flash(:info, "Brand updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_brand(socket, :new, brand_params) do
    case Marketplaces.create_brand(brand_params) do
      {:ok, _brand} ->
        # TODO: Assoc brand to current user

        {:noreply,
         socket
         |> put_flash(:info, "Brand created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
