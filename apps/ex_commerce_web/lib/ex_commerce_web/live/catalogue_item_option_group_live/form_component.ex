defmodule ExCommerceWeb.CatalogueItemOptionGroupLive.FormComponent do
  @moduledoc """
  Form for catalogue item option groups create/edit actions
  """
  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  import ExCommerceWeb.Utils

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
      |> prepare_options_maybe(assigns)

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
    %CatalogueItemOptionGroup{brand_id: brand_id} =
      socket.assigns.changeset.data

    changeset =
      socket.assigns.changeset.data
      |> Offerings.change_catalogue_item_option_group(
        catalogue_item_option_group_params
        |> assign_brand_id(brand_id)
        |> maybe_assign_catalogue_item(socket.assigns.catalogue_items)
        |> maybe_assign_catalogue_item_variant()
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

  def handle_event("add_option", _params, socket) do
    existing_options =
      Map.get(
        socket.assigns.changeset.changes,
        :options,
        socket.assigns.catalogue_item_option_group.options
      )

    %Ecto.Changeset{data: %CatalogueItemOptionGroup{brand_id: brand_id}} =
      socket.assigns.changeset

    options =
      existing_options
      |> Enum.concat([
        Offerings.change_catalogue_item_option(%CatalogueItemOption{
          brand_id: brand_id,
          temp_id: get_temp_id(),
          is_visible: false,
          price_modifier: 0
        })
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:options, options)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_option", %{"remove" => remove_id}, socket) do
    options =
      socket.assigns.changeset.changes.options
      |> Enum.reject(fn %{data: option} ->
        option.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:options, options)

    {:noreply, assign(socket, changeset: changeset)}
  end

  defp prepare_options_maybe(
         %Ecto.Changeset{data: %CatalogueItemOptionGroup{brand_id: brand_id}} =
           changeset,
         %{action: :new}
       ) do
    catalogue_item_option =
      Offerings.change_catalogue_item_option(%CatalogueItemOption{
        brand_id: brand_id,
        temp_id: get_temp_id(),
        is_visible: false,
        price_modifier: 0
      })

    changeset
    |> Ecto.Changeset.put_assoc(:options, [catalogue_item_option])
  end

  defp prepare_options_maybe(changeset, %{action: _action}), do: changeset

  defp save_catalogue_item_option_group(
         socket,
         :edit,
         catalogue_item_option_group_params
       ) do
    %{
      assigns: %{
        catalogue_item_option_group: %CatalogueItemOptionGroup{
          brand_id: brand_id
        }
      }
    } = socket

    case Offerings.update_catalogue_item_option_group(
           socket.assigns.catalogue_item_option_group,
           catalogue_item_option_group_params
           |> assign_brand_id(brand_id)
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
      catalogue_item_option_group_params
      |> assign_brand_id(brand_id)

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

  # ----------------------------------------------------------------------------
  # Assigns helpers
  #

  defp assign_brand_id(%{"options" => options} = params, brand_id) do
    options =
      options
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, Map.merge(value, %{"brand_id" => brand_id}))
      end)

    Map.merge(params, %{"brand_id" => brand_id, "options" => options})
  end

  defp assign_brand_id(params, brand_id),
    do: Map.merge(params, %{"brand_id" => brand_id})

  defp maybe_assign_catalogue_item(
         %{"options" => options} = params,
         catalogue_items
       ) do
    options =
      options
      |> Enum.reduce(
        options,
        fn
          {_key, %{"catalogue_item_id" => ""}}, acc ->
            acc

          {key, %{"catalogue_item_id" => catalogue_item_id} = value}, acc ->
            find_catalogue_item_by_id(catalogue_items, catalogue_item_id)
            |> case do
              nil ->
                acc

              %CatalogueItem{} = catalogue_item ->
                Map.put(
                  acc,
                  key,
                  Map.put(value, "catalogue_item", catalogue_item)
                )
            end

          _option, acc ->
            acc
        end
      )

    Map.put(params, "options", options)
  end

  defp maybe_assign_catalogue_item(params, _catalogue_items), do: params

  defp maybe_assign_catalogue_item_variant(%{"options" => options} = params) do
    options =
      options
      |> Enum.reduce(
        options,
        fn
          {_key, %{"catalogue_item_id" => ""}}, acc ->
            acc

          {_key, %{"catalogue_item_variant_id" => ""}}, acc ->
            acc

          {key,
           %{
             "catalogue_item_variant_id" => catalogue_item_variant_id,
             "catalogue_item" => %CatalogueItem{variants: variants}
           } = value},
          acc ->
            case find_catalogue_item_variant_by_id(
                   variants,
                   catalogue_item_variant_id
                 ) do
              nil ->
                acc

              %CatalogueItemVariant{} = catalogue_item_variant ->
                Map.put(
                  acc,
                  key,
                  Map.put(
                    value,
                    "catalogue_item_variant",
                    catalogue_item_variant
                  )
                )
            end

          _option, acc ->
            acc
        end
      )

    Map.put(params, "options", options)
  end

  defp maybe_assign_catalogue_item_variant(params), do: params

  # ----------------------------------------------------------------------------
  # Catalogue item selection helpers
  #

  defp get_catalogue_items_prompt([], %Phoenix.HTML.Form{} = _current_option),
    do: gettext("Create some items first")

  defp get_catalogue_items_prompt(
         _catalogue_items,
         %Phoenix.HTML.Form{
           data: %ExCommerce.Offerings.CatalogueItemOption{
             catalogue_item_id: catalogue_item_id
           },
           source: %Ecto.Changeset{changes: changes}
         } = _current_option
       )
       when not is_nil(catalogue_item_id) or
              is_map_key(changes, :catalogue_item_id),
       do: nil

  defp get_catalogue_items_prompt(
         _catalogue_items,
         %Phoenix.HTML.Form{} = _current_option
       ),
       do: gettext("Select an item")

  defp is_catalogue_item_disabled([]), do: true

  defp is_catalogue_item_disabled(_catalogue_items), do: false

  defp get_selected_catalogue_items(_catalogue_items), do: nil

  defp build_catalogue_item_options(catalogue_items) do
    Enum.map(catalogue_items, &{&1.code, &1.id})
  end

  defp find_catalogue_item_by_id(catalogue_items, catalogue_item_id) do
    Enum.find(catalogue_items, nil, fn %CatalogueItem{id: id} ->
      id == catalogue_item_id
    end)
  end

  # ----------------------------------------------------------------------------
  # Catalogue item variant selection helpers
  #

  # A catalogue item is present but no variants are available
  defp get_catalogue_item_variant_prompt(
         [],
         %Phoenix.HTML.Form{
           data: %ExCommerce.Offerings.CatalogueItemOption{
             catalogue_item_id: catalogue_item_id
           },
           source: %Ecto.Changeset{changes: changes}
         } = _current_option
       )
       when not is_nil(catalogue_item_id) or
              is_map_key(changes, :catalogue_item_id),
       do: gettext("Create a variant for this item first")

  # No variants are present in the form
  defp get_catalogue_item_variant_prompt(
         [],
         %Phoenix.HTML.Form{} = _current_option
       ),
       do: gettext("Select an item first")

  # Variants and a catalogue item are present
  defp get_catalogue_item_variant_prompt(
         _variants,
         %Phoenix.HTML.Form{
           data: %ExCommerce.Offerings.CatalogueItemOption{
             catalogue_item_variant_id: catalogue_item_variant_id
           },
           source: %Ecto.Changeset{changes: changes}
         } = _current_option
       )
       when not is_nil(catalogue_item_variant_id) or
              is_map_key(changes, :catalogue_item_variant_id),
       do: nil

  # Variants are present but no catalogue item has been selected yet
  defp get_catalogue_item_variant_prompt(
         _variants,
         %Phoenix.HTML.Form{} = _current_option
       ),
       do: gettext("Select a variant")

  # No varianst available
  defp is_catalogue_item_variant_disabled(
         [],
         %Phoenix.HTML.Form{} = _current_option
       ),
       do: true

  # No db data or user input is present for catalogue item id
  defp is_catalogue_item_variant_disabled(
         _options,
         %Phoenix.HTML.Form{
           data: %ExCommerce.Offerings.CatalogueItemOption{
             catalogue_item_id: catalogue_item_id
           },
           source: %Ecto.Changeset{changes: changes}
         } = _current_option
       )
       when is_nil(catalogue_item_id) and
              not is_map_key(changes, :catalogue_item_id),
       do: true

  defp is_catalogue_item_variant_disabled(
         _options,
         %Phoenix.HTML.Form{} = _current_option
       ),
       do: false

  defp find_catalogue_item_variant_by_id(
         catalogue_item_variants,
         catalogue_item_variant_id
       ) do
    Enum.find(catalogue_item_variants, nil, fn %CatalogueItemVariant{id: id} ->
      id == catalogue_item_variant_id
    end)
  end

  # No db data or user input is present for catalogue item id
  defp get_catalogue_item_variant_options(
         _changeset,
         _catalogue_items,
         %Phoenix.HTML.Form{
           data: %ExCommerce.Offerings.CatalogueItemOption{
             catalogue_item_id: nil
           },
           source: %Ecto.Changeset{changes: changes}
         } = _current_option
       )
       when not is_map_key(changes, :catalogue_item_id),
       do: []

  # Only db data is present for catalogue item id
  defp get_catalogue_item_variant_options(
         _changeset,
         catalogue_items,
         %Phoenix.HTML.Form{
           data: %ExCommerce.Offerings.CatalogueItemOption{
             catalogue_item_id: current_catalogue_item_id
           },
           source: %Ecto.Changeset{changes: changes}
         } = _current_option
       )
       when not is_map_key(changes, :catalogue_item_id) do
    %CatalogueItem{variants: variants} =
      find_catalogue_item_by_id(catalogue_items, current_catalogue_item_id)

    build_catalogue_item_variant_options(variants)
  end

  # User input is present for catalogue item id
  defp get_catalogue_item_variant_options(
         _changeset,
         catalogue_items,
         %Phoenix.HTML.Form{
           source: %Ecto.Changeset{changes: changes}
         } = _current_option
       )
       when is_map_key(changes, :catalogue_item_id) do
    %CatalogueItem{variants: variants} =
      find_catalogue_item_by_id(
        catalogue_items,
        Map.fetch!(changes, :catalogue_item_id)
      )

    build_catalogue_item_variant_options(variants)
  end

  defp build_catalogue_item_variant_options(variants),
    do: Enum.map(variants, &{"#{&1.type} - #{&1.price}", &1.id})
end
