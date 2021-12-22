defmodule ExCommerceWeb.CatalogueItemLive.FormComponent do
  @moduledoc """
  Form for catalogue items create/edit actions
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
    changeset =
      socket.assigns.catalogue_item
      |> Offerings.change_catalogue_item(
        catalogue_item_params
        # |> maybe_assign_catalogue_item_option_groups(socket.assigns.catalogue_item_option_groups)
      )
      |> Map.put(:action, :validate)
      |> IO.inspect(label: "validate")

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

  def handle_event("add_option_group", _params, socket) do
    existing_option_groups =
      Map.get(
        socket.assigns.changeset.changes,
        :option_groups,
        socket.assigns.catalogue_item.option_groups
      )

    %Ecto.Changeset{data: %CatalogueItem{brand_id: brand_id}} =
      socket.assigns.changeset

    option_groups =
      existing_option_groups
      |> Enum.concat([
        Offerings.change_catalogue_item_option_group(%CatalogueItemOptionGroup{
          temp_id: get_temp_id(),
          brand_id: brand_id,
          mandatory: false,
          max_selection: nil,
          multiple_selection: false,
          name: "",
          description: "",
          options: []
        })
      ])

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:option_groups, option_groups)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove_option_group", %{"remove" => remove_id}, socket) do
    option_groups =
      socket.assigns.changeset.changes.option_groups
      |> Enum.reject(fn %{data: option_group} ->
        option_group.temp_id == remove_id
      end)

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:option_groups, option_groups)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "add_option_group_option",
        %{"option_group" => option_group_temp_id},
        socket
      ) do
    option_groups =
      Enum.map(
        socket.assigns.changeset.changes.option_groups,
        fn %Ecto.Changeset{
             data:
               %CatalogueItemOptionGroup{temp_id: temp_id, options: options} =
                 option_group
           } = changeset ->
          case temp_id do
            ^option_group_temp_id ->
              %CatalogueItemOptionGroup{brand_id: brand_id} = option_group

              existing_options = Map.get(changeset.changes, :options, options)

              option_group_options =
                existing_options
                |> Enum.concat([
                  Offerings.change_catalogue_item_option(%CatalogueItemOption{
                    brand_id: brand_id,
                    temp_id: get_temp_id(),
                    is_visible: false,
                    price_modifier: 0
                  })
                ])

              changeset
              |> Ecto.Changeset.put_assoc(:options, option_group_options)

            _temp_id ->
              changeset
          end
        end
      )

    %Ecto.Changeset{} =
      changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:option_groups, option_groups)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "remove_option_group_option",
        %{"option_group" => option_group_temp_id, "remove" => remove_id},
        socket
      ) do
    %Ecto.Changeset{changes: %{option_groups: option_groups}} =
      socket.assigns.changeset

    option_groups =
      Enum.map(option_groups, fn %Ecto.Changeset{
                                   data: %CatalogueItemOptionGroup{
                                     temp_id: og_temp_id,
                                     options: options
                                   }
                                 } = changeset ->
        case og_temp_id do
          ^option_group_temp_id ->
            existing_options = Map.get(changeset.changes, :options, options)

            options =
              Enum.reject(existing_options, fn %Ecto.Changeset{
                                                 data: %CatalogueItemOption{
                                                   temp_id: option_temp_id
                                                 }
                                               } ->
                option_temp_id == remove_id
              end)

            changeset
            |> Ecto.Changeset.put_assoc(:options, options)

          _option_group_temp_id ->
            changeset
        end
      end)

    %Ecto.Changeset{} =
      changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:option_groups, option_groups)

    {:noreply, assign(socket, changeset: changeset)}
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
      Map.merge(catalogue_item_params, %{"brand_id" => brand_id})

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

  defp maybe_assign_catalogue_item_option_groups(
         %{"option_groups" => option_group_ids} = params,
         catalogue_item_option_groups
       ) do
    IO.inspect(params, label: "params!")

    IO.inspect(catalogue_item_option_groups,
      label: "catalogue_item_option_groups!"
    )

    option_groups =
      Enum.map(
        option_group_ids,
        fn option_group_id ->
          find_catalogue_item_option_group_by_id(
            catalogue_item_option_groups,
            option_group_id
          )
        end
      )

    Map.put(params, "option_groups", option_groups)
    |> IO.inspect(label: "ASSIGNED OPTION GROUPS")
  end

  defp maybe_assign_catalogue_item_option_groups(
         params,
         _catalogue_item_option_groups
       ),
       do: params

  # ----------------------------------------------------------------------------
  # Catalogue item option groups selection helpers
  #

  def get_catalogue_item_option_groups_prompt(_options, _form) do
    "Select Option Groups"
  end

  def is_catalogue_item_option_groups_disabled(_options) do
    false
  end

  def get_selected_catalogue_item_option_groups(_options) do
    []
  end

  def build_catalogue_item_option_group_options(catalogue_item_option_groups) do
    # IO.inspect(catalogue_item_option_groups, label: "catalogue_item_option_groups")

    Enum.map(catalogue_item_option_groups, &{&1.name, &1.id})
  end

  defp find_catalogue_item_option_group_by_id(
         catalogue_item_option_groups,
         catalogue_item_option_group_id
       ) do
    Enum.find(catalogue_item_option_groups, nil, fn %CatalogueItemOptionGroup{
                                                      id: id
                                                    } ->
      id == catalogue_item_option_group_id
    end)
  end
end
