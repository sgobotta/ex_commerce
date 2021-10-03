defmodule ExCommerceWeb.CatalogueLive.FormComponent do
  @moduledoc """
  Form for catalogues create/edit actions
  """

  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.Catalogue

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
    changeset =
      socket.assigns.catalogue
      |> Offerings.change_catalogue(catalogue_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"catalogue" => catalogue_params}, socket) do
    save_catalogue(socket, socket.assigns.action, catalogue_params)
  end

  defp save_catalogue(socket, :edit, catalogue_params) do
    case Offerings.update_catalogue(
           socket.assigns.catalogue,
           catalogue_params
         ) do
      {:ok, %Catalogue{} = _catalogue} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue(socket, :new, catalogue_params) do
    %{assigns: %{catalogue: %Catalogue{brand_id: brand_id}}} = socket
    catalogue_params = Map.merge(catalogue_params, %{"brand_id" => brand_id})

    case Offerings.create_catalogue(catalogue_params) do
      {:ok, %Catalogue{} = _catalogue} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
