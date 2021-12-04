defmodule ExCommerceWeb.CatalogueItemOptionGroupLive.FormComponent do
  @moduledoc """
  Form for catalogue item option groups create/edit actions
  """
  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItemOptionGroup

  @impl true
  def update(
        %{
          catalogue_item_option_group:
            %CatalogueItemOptionGroup{} = catalogue_item_option_group
        } = assigns,
        socket
      ) do
    changeset =
      Offerings.change_catalogue_item_option_group(catalogue_item_option_group)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"catalogue_item_option_group" => catalogue_item_option_group_params},
        socket
      ) do
    changeset =
      socket.assigns.catalogue_item_option_group
      |> Offerings.change_catalogue_item_option_group(
        catalogue_item_option_group_params
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "save",
        %{"catalogue_item_option_group" => catalogue_item_option_group_params},
        socket
      ) do
    save_catalogue_item_option_group(
      socket,
      socket.assigns.action,
      catalogue_item_option_group_params
    )
  end

  defp save_catalogue_item_option_group(
         socket,
         :edit,
         catalogue_item_option_group_params
       ) do
    case Offerings.update_catalogue_item_option_group(
           socket.assigns.catalogue_item_option_group,
           catalogue_item_option_group_params
         ) do
      {:ok, %CatalogueItemOptionGroup{} = _catalogue_item_option_group} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           gettext("Catalogue item option group updated successfully")
         )
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue_item_option_group(
         socket,
         :new,
         catalogue_item_option_group_params
       ) do
    %{
      assigns: %{
        catalogue_item_option_group: %CatalogueItemOptionGroup{
          brand_id: brand_id
        }
      }
    } = socket

    catalogue_item_option_group_params =
      Map.merge(catalogue_item_option_group_params, %{"brand_id" => brand_id})

    case Offerings.create_catalogue_item_option_group(
           catalogue_item_option_group_params
         ) do
      {:ok, %CatalogueItemOptionGroup{} = _catalogue_item_option_group} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           gettext("Catalogue item option group created successfully")
         )
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
