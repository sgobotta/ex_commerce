defmodule ExCommerceWeb.CatalogueItemOptionGroupLive.FormComponent do
  @moduledoc """
  Form for catalogue item option groups create/edit actions
  """
  use ExCommerceWeb, :live_component

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItemOption
  alias ExCommerce.Offerings.CatalogueItemOptionGroup

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
    # IO.inspect(catalogue_item_option_group_params, label:
    #   "\n\n\ncatalogue_item_option_group_params")
    %CatalogueItemOptionGroup{brand_id: brand_id} =
      socket.assigns.changeset.data

    changeset =
      socket.assigns.changeset.data
      |> Offerings.change_catalogue_item_option_group(
        catalogue_item_option_group_params
        |> assign_brand_id(brand_id)
        # |> IO.inspect(label: "\n\n\nAfter assigned brand id")
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

  defp assign_brand_id(%{"options" => options} = params, brand_id) do
    options =
      options
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, Map.merge(value, %{"brand_id" => brand_id}))
      end)

    Map.merge(params, %{"brand_id" => brand_id, "options" => options})
  end

  defp assign_brand_id(params, brand_id) do
    Map.merge(params, %{"brand_id" => brand_id})
  end

  defp get_catalogue_item_variants(changeset, catalogue_items, o) do
    # IO.inspect(changeset.changes.options, label: "\n\nCHANGESET")
    # IO.inspect(o, label: "OOO")
    [{gettext("Choose an item first"), nil}]
  end
end
