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

  def handle_event("add_option", _params, socket) do
    existing_options =
      Map.get(
        socket.assigns.changeset.changes,
        :options,
        socket.assigns.catalogue_item_option_group.options
      )

    options =
      existing_options
      |> Enum.concat([
        Offerings.change_catalogue_item_option(%CatalogueItemOption{
          brand_id: Ecto.UUID.generate(),
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
