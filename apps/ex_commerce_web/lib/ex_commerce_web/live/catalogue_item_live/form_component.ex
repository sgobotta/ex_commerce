defmodule ExCommerceWeb.CatalogueItemLive.FormComponent do
  @moduledoc """
  Form for catalogue items create/edit actions
  """
  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  import ExCommerceWeb.{
    LiveFormHelpers,
    Utils
  }

  @impl true
  def update(
        %{catalogue_item: %CatalogueItem{} = catalogue_item} = assigns,
        socket
      ) do
    changeset =
      Offerings.change_catalogue_item(catalogue_item)
      |> prepare_variants_maybe(assigns)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"catalogue_item" => catalogue_item_params},
        socket
      ) do
    %Ecto.Changeset{data: %CatalogueItem{brand_id: brand_id}} =
      socket.assigns.changeset

    changeset =
      socket.assigns.catalogue_item
      |> Offerings.change_catalogue_item(
        catalogue_item_params
        |> assign_brand_id_param(brand_id)
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"catalogue_item" => catalogue_item_params}, socket) do
    save_catalogue_item(socket, socket.assigns.action, catalogue_item_params)
  end

  def handle_event("add_variant", _params, socket) do
    existing_variants =
      Map.get(
        socket.assigns.changeset.changes,
        :variants,
        socket.assigns.catalogue_item.variants
      )

    variants =
      existing_variants
      |> Enum.concat([
        Offerings.change_catalogue_item_variant(%CatalogueItemVariant{
          temp_id: get_temp_id(),
          type: nil,
          price: 0
        })
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:variants, variants)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_variant", %{"remove" => remove_id}, socket) do
    variants =
      socket.assigns.changeset.changes.variants
      |> Enum.reject(fn %{data: variant} ->
        variant.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:variants, variants)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("create_option_group", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(
       to:
         Routes.catalogue_item_option_group_index_path(
           socket,
           :new,
           socket.assigns.catalogue_item.brand_id,
           redirect_to: socket.assigns.return_from_group_form
         )
     )}
  end

  defp prepare_variants_maybe(changeset, %{action: :new}) do
    catalogue_item_variant =
      Offerings.change_catalogue_item_variant(%CatalogueItemVariant{
        temp_id: get_temp_id(),
        type: nil,
        price: 0
      })

    changeset
    |> Ecto.Changeset.put_assoc(:variants, [catalogue_item_variant])
  end

  defp prepare_variants_maybe(changeset, %{action: _action}), do: changeset

  defp save_catalogue_item(socket, :edit, catalogue_item_params) do
    case Offerings.update_catalogue_item(
           socket.assigns.catalogue_item,
           catalogue_item_params
         ) do
      {:ok, _catalogue_item} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue item updated successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue_item(socket, :new, catalogue_item_params) do
    %{assigns: %{catalogue_item: %CatalogueItem{brand_id: brand_id}}} = socket

    catalogue_item_params =
      assign_brand_id_param(catalogue_item_params, brand_id)

    case Offerings.create_catalogue_item(catalogue_item_params) do
      {:ok, _catalogue_item} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue item created successfully"))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # ----------------------------------------------------------------------------
  # Assigns helpers
  #

  # ----------------------------------------------------------------------------
  # Catalogue item option groups selection helpers
  #

  def get_selected_catalogue_item_option_groups(%Phoenix.HTML.Form{
        source: %Ecto.Changeset{
          changes: %{
            option_groups: option_groups
          }
        }
      }) do
    Enum.map(option_groups, fn %Ecto.Changeset{
                                 data: %CatalogueItemOptionGroup{id: id}
                               } ->
      id
    end)
  end

  def get_selected_catalogue_item_option_groups(%Phoenix.HTML.Form{}), do: []

  def build_catalogue_item_option_group_options(catalogue_item_option_groups) do
    Enum.map(catalogue_item_option_groups, fn %CatalogueItemOptionGroup{
                                                id: id,
                                                name: name
                                              } ->
      {name, id}
    end)
  end
end
