defmodule ExCommerceWeb.CatalogueItemLive.FormComponent do
  @moduledoc """
  Form for catalogue items create/edit actions
  """
  use ExCommerceWeb, :live_component

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Marketplaces.Brand

  alias ExCommerce.{Offerings, Photos}

  alias ExCommerce.Offerings.{
    CatalogueCategory,
    CatalogueItem,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  import ExCommerceWeb.{
    LiveFormHelpers,
    Utils
  }

  @uploads_path get_uploads_path()

  @impl true
  @spec mount(Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(socket) do
    {:ok,
     allow_upload(
       socket,
       :photos,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 2_000_000,
       auto_upload: true
     )}
  end

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
           redirect_to: socket.assigns.current_route
         )
     )}
  end

  def handle_event("create_category", _params, socket) do
    {:noreply,
     socket
     |> push_redirect(
       to:
         Routes.catalogue_category_index_path(
           socket,
           :new,
           socket.assigns.catalogue_item.brand_id,
           redirect_to: socket.assigns.current_route
         )
     )}
  end

  def handle_event("cancel_entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photos, ref)}
  end

  # ----------------------------------------------------------------------------
  # Private helpers
  #

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
    catalogue_item_params =
      put_uploads(
        socket,
        catalogue_item_params,
        &build_photo_by_upload_entry/2,
        &assign_photos_param/2,
        attr: :photos
      )

    case Offerings.update_catalogue_item(
           socket.assigns.catalogue_item,
           catalogue_item_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, %CatalogueItem{} = _catalogue_item} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue item updated successfully"))
         |> redirect_or_return()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_catalogue_item(socket, :new, catalogue_item_params) do
    %{assigns: %{catalogue_item: %CatalogueItem{brand_id: brand_id}}} = socket

    catalogue_item_params =
      put_uploads(
        socket,
        catalogue_item_params,
        &build_photo_by_upload_entry/2,
        &assign_photos_param/2,
        attr: :photos
      )
      |> assign_brand_id_param(brand_id)

    case Offerings.create_catalogue_item(
           catalogue_item_params,
           &consume_photos(socket, &1)
         ) do
      {:ok, _catalogue_item} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Catalogue item created successfully"))
         |> redirect_or_return()}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  # ----------------------------------------------------------------------------
  # File upload helpers
  #

  defp build_photo_by_upload_entry(socket, entry) do
    %{brand: %Brand{id: brand_id}} = socket.assigns
    %{uuid: uuid} = entry
    extension = ext(entry)

    Photos.create_photo(%{
      local_path: Routes.static_path(socket, "/uploads/#{uuid}.#{extension}"),
      full_local_path: Path.join(@uploads_path, "#{uuid}.#{extension}"),
      uuid: uuid,
      brand_id: brand_id
    })
  end

  defp assign_photos_param(socket, new_photos) do
    %{catalogue_item: %CatalogueItem{photos: photos}} = socket.assigns

    new_photos ++ photos
  end

  defp consume_photos(socket, %CatalogueItem{photos: photos} = catalogue_item) do
    %{brand: %Brand{id: brand_id}} = socket.assigns
    upload_opts = [folder: brand_id, tags: brand_id]

    # Consumes uploads via the live form helper
    {old_photos, new_photos} =
      consume_uploads(
        socket,
        :photos,
        @uploads_path,
        upload_opts,
        photos
      )

    # Saves new photos
    {:ok, %CatalogueItem{} = catalogue_item} =
      Offerings.update_catalogue_item(catalogue_item, %{
        photos: new_photos ++ old_photos
      })

    {:ok, catalogue_item}
  end

  # ----------------------------------------------------------------------------
  # Photo form helpers: imported from LiveHelpers
  #

  # ----------------------------------------------------------------------------
  # Catalogue item option groups selection helpers
  #

  defp get_selected_catalogue_item_option_groups(%Phoenix.HTML.Form{
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

  defp get_selected_catalogue_item_option_groups(%Phoenix.HTML.Form{}), do: []

  defp build_catalogue_item_option_group_options(catalogue_item_option_groups) do
    Enum.map(catalogue_item_option_groups, fn %CatalogueItemOptionGroup{
                                                id: id,
                                                name: name
                                              } ->
      {name, id}
    end)
  end

  # ----------------------------------------------------------------------------
  # Catalogue item categories selection helpers
  #

  defp get_selected_catalogue_item_categories(%Phoenix.HTML.Form{
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

  defp get_selected_catalogue_item_categories(%Phoenix.HTML.Form{}), do: []

  defp build_catalogue_item_category_options(catalogue_categories) do
    Enum.map(catalogue_categories, fn %CatalogueCategory{
                                        id: id,
                                        code: code
                                      } ->
      {code, id}
    end)
  end
end
