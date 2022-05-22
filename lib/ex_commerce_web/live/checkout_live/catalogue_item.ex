defmodule ExCommerceWeb.CheckoutLive.CatalogueItem do
  @moduledoc """
  Live Checkout: catalogue item section
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_checkout.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.OrderItem

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  @impl true
  def mount(params, session, socket) do
    {
      :ok,
      socket
      |> assign_public_defaults(params, session)
      |> assign_shop_by_slug_or_redirect(params)
      |> assign(:cart_visible, false)
      |> assign(:brand_slug, params["brand"])
      |> assign(:shop_slug, params["shop"])
      |> assign(:quantity, 1)
    }
  end

  @impl true
  def handle_params(params, _session, socket),
    do: {:noreply, apply_action(socket, socket.assigns.live_action, params)}

  @impl true
  def handle_event(
        "remove_item",
        _params,
        %{assigns: %{changeset: %Ecto.Changeset{changes: %{quantity: 1}}}} =
          socket
      ),
      do: {:noreply, socket}

  def handle_event(
        "remove_item",
        _params,
        %{
          assigns: %{
            changeset: %Ecto.Changeset{changes: %{quantity: quantity} = changes},
            order_item: %OrderItem{} = order_item
          }
        } = socket
      ),
      do:
        {:noreply,
         assign(
           socket,
           :changeset,
           Checkout.change_order_item(
             order_item,
             Map.merge(changes, %{quantity: quantity - 1})
           )
           |> Map.put(:action, :validate)
         )}

  def handle_event(
        "add_item",
        _params,
        %{
          assigns: %{
            changeset: %Ecto.Changeset{changes: %{quantity: quantity} = changes},
            order_item: %OrderItem{} = order_item
          }
        } = socket
      ) do
    {:noreply,
     assign(
       socket,
       :changeset,
       Checkout.change_order_item(
         order_item,
         Map.merge(changes, %{quantity: quantity + 1})
       )
       |> Map.put(:action, :validate)
     )}
  end

  def handle_event("select_variant", %{"value" => variant_id}, socket) do
    %{
      changeset: %Ecto.Changeset{changes: changes},
      order_item: %OrderItem{} = order_item
    } = socket.assigns

    changeset =
      Checkout.change_order_item(
        order_item,
        Map.merge(changes, %{variant_id: variant_id})
      )
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "check_option",
        %{
          "value" => _on,
          "option_group_id" => option_group_id,
          "option_id" => option_id
        },
        socket
      ) do
    %{
      changeset: %Ecto.Changeset{changes: changes} = changeset,
      order_item: %OrderItem{} = order_item
    } = socket.assigns

    changeset =
      case get_option_group_rules(changeset, option_group_id) do
        nil ->
          changeset

        rules ->
          %{multiple_selection: multiple_selection} = rules

          if multiple_selection &&
               valid_option?(changes, rules, option_group_id, option_id) do
            option_groups = Map.get(changes, :option_groups, Map.new())
            options = Map.get(option_groups, option_group_id, []) ++ [option_id]

            Checkout.change_order_item(
              order_item,
              Map.merge(changes, %{
                option_groups: Map.put(option_groups, option_group_id, options)
              })
            )
            |> Map.put(:action, :validate)
          else
            changeset
          end
      end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "check_option",
        %{"option_group_id" => option_group_id, "option_id" => option_id},
        socket
      ) do
    %{
      changeset: %Ecto.Changeset{changes: changes} = changeset,
      order_item: %OrderItem{} = order_item
    } = socket.assigns

    changeset =
      case get_option_group_rules(changeset, option_group_id) do
        nil ->
          changeset

        rules ->
          %{multiple_selection: multiple_selection} = rules

          if multiple_selection && valid_option?(rules, option_id) do
            option_groups = Map.get(changes, :option_groups, Map.new())
            options = Map.get(option_groups, option_group_id, []) -- [option_id]

            Checkout.change_order_item(
              order_item,
              Map.merge(changes, %{
                option_groups: Map.put(option_groups, option_group_id, options)
              })
            )
            |> Map.put(:action, :validate)
          else
            changeset
          end
      end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "choose_option",
        %{"value" => option_id, "option_group_id" => option_group_id},
        socket
      ) do
    %{
      changeset: %Ecto.Changeset{changes: changes} = changeset,
      order_item: %OrderItem{} = order_item
    } = socket.assigns

    changeset =
      case get_option_group_rules(changeset, option_group_id) do
        nil ->
          changeset

        rules ->
          if valid_option?(rules, option_id) do
            option_groups = Map.get(changes, :option_groups, Map.new())

            Checkout.change_order_item(
              order_item,
              Map.merge(changes, %{
                option_groups:
                  Map.put(option_groups, option_group_id, option_id)
              })
            )
            |> Map.put(:action, :validate)
          else
            changeset
          end
      end

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"order_item" => _order_item}, socket) do
    changeset =
      socket.assigns.order_item
      |> Checkout.change_order_item(%{})
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  # ----------------------------------------------------------------------------
  # Render functions
  #

  def render_option_price(price, price_modifier, assigns) do
    case Decimal.eq?(price_modifier, Decimal.new(0)) do
      true ->
        ~H"""
        <p class="font-medium text-sm text-black">
          <%= get_price(price) %>
        </p>
        """

      false ->
        ~H"""
        <p class="font-medium text-sm text-black line line-through">
          <%= get_price(price) %>
        </p>
        <p class="font-medium text-sm text-green-400">
          <%= get_price(price, price_modifier) %>
        </p>
        """
    end
  end

  # ----------------------------------------------------------------------------
  # Private functions
  #

  defp assign_changeset(socket) do
    %{
      assigns: %{
        catalogue_item:
          %CatalogueItem{
            id: catalogue_item_id,
            option_groups: option_groups,
            variants: variants
          } = _ci
      }
    } = socket

    order_item = %OrderItem{
      catalogue_item_id: catalogue_item_id,
      variant_id: nil,
      variants: variants,
      available_option_groups: %{
        values: option_groups,
        rules:
          Enum.map(option_groups, fn %CatalogueItemOptionGroup{
                                       id: id,
                                       mandatory: mandatory,
                                       max_selection: max_selection,
                                       multiple_selection: multiple_selection,
                                       options: options
                                     } ->
            %{
              available_options:
                Enum.map(options, fn %CatalogueItemOption{id: id} ->
                  id
                end),
              id: id,
              mandatory: mandatory,
              max_selection: max_selection,
              multiple_selection: multiple_selection
            }
          end)
      }
    }

    socket
    |> assign(:order_item, order_item)
    |> assign(
      :changeset,
      Checkout.change_order_item(order_item, %{
        quantity: 1,
        option_groups: assign_option_groups(option_groups)
      })
    )
  end

  defp apply_action(socket, :index, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id,
         "item" => catalogue_item_id
       }) do
    socket
    |> assign(:page_title, gettext("[Catalogue Item Name]"))
    |> assign(
      :return_to,
      Routes.checkout_catalogue_path(
        socket,
        :index,
        brand_slug,
        shop_slug,
        catalogue_id
      )
    )
    |> assign_catalogue(catalogue_id)
    |> assign_catalogue_item(catalogue_item_id)
    |> assign_changeset()
    |> assign_photos_sources()
    |> assign_nav_title()
  end

  defp assign_photos_sources(
         %{assigns: %{catalogue_item: %CatalogueItem{photos: photos}}} = socket
       ) do
    item_photo_source =
      get_photos(photos,
        use_placeholder: true,
        type: :avatar
      )
      |> Enum.map(&get_photo_source(socket, &1))
      |> hd()

    socket
    |> assign(:item_photo_source, item_photo_source)
  end

  defp assign_option_groups(option_groups) do
    Enum.reduce(option_groups, Map.new(), fn %CatalogueItemOptionGroup{
                                               id: option_group_id,
                                               multiple_selection:
                                                 multiple_selection
                                             },
                                             acc ->
      initial_value =
        case multiple_selection do
          true ->
            []

          false ->
            nil
        end

      Map.put(acc, option_group_id, initial_value)
    end)
  end

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp assign_catalogue_item(socket, catalogue_item_id),
    do: assign_catalogue_item_by_id_or_redirect(socket, catalogue_item_id)

  defp assign_nav_title(socket) do
    socket
    |> assign(:nav_title, gettext("Back"))
  end

  defp get_price(price) do
    price
    |> ExCommerceNumeric.format_price()
    |> prepend_currency()
  end

  defp get_price(price, price_modifier) do
    price =
      price
      |> ExCommerceNumeric.format_price()

    price_modifier = ExCommerceNumeric.format_price(price_modifier)

    CatalogueItemOption.apply_discount(price, price_modifier)
    |> prepend_currency()
  end

  defp prepend_currency(price), do: "$#{price}"

  defp get_quantity(%Ecto.Changeset{changes: changes}), do: changes.quantity

  defp variant_selected?(%Ecto.Changeset{changes: changes}, variant_id),
    do: Map.get(changes, :variant_id) == variant_id

  defp is_option_checked(changeset, option_group_id, option_id) do
    case Map.has_key?(changeset.changes, :option_groups) do
      true ->
        Map.get(changeset.changes.option_groups, option_group_id) == option_id

      false ->
        false
    end
  end

  defp multiple_option_checked?(changeset, option_group_id, option_id) do
    case Map.has_key?(changeset.changes, :option_groups) do
      true ->
        Map.get(changeset.changes.option_groups, option_group_id, [])
        |> Enum.member?(option_id)

      false ->
        false
    end
  end

  defp get_option_group_rules(%Ecto.Changeset{data: data}, option_group_id),
    do:
      Enum.find(data.available_option_groups.rules, fn %{id: id} ->
        id == option_group_id
      end)

  defp valid_option?(rules, option_id),
    do: Enum.find(rules.available_options, fn id -> id == option_id end) !== nil

  defp valid_option?(changes, rules, option_group_id, option_id) do
    case valid_option?(rules, option_id) do
      true ->
        %{max_selection: max_selection} = rules

        options_length =
          Map.get(changes, :option_groups, %{option_group_id => []})
          |> Map.get(option_group_id, [])
          |> length()

        options_length + 1 <= max_selection

      false ->
        false
    end
  end

  defp multiple_select_disabled?(changeset, option_group_id, option_id) do
    case get_option_group_rules(changeset, option_group_id) do
      nil ->
        true

      rules ->
        %{max_selection: max_selection} = rules

        options =
          Map.get(changeset.changes, :option_groups, %{option_group_id => []})
          |> Map.get(option_group_id, [])

        length(options) >= max_selection && !Enum.member?(options, option_id)
    end
  end

  defp valid_form?(%Ecto.Changeset{} = changeset) do
    # IO.inspect(changeset.data, label: "Data")
    # IO.inspect(changeset.changes, label: "Changes")
    # IO.inspect(changeset, label: "Changeset")

    false
  end
end
