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
  alias ExCommerce.Checkout.Cart
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
      |> assign(:cart_visible, true)
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
            changeset: %Ecto.Changeset{
              changes: %{quantity: quantity} = changes
            },
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
            changeset: %Ecto.Changeset{
              changes: %{quantity: quantity} = changes
            },
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

  def handle_event("select_variant", %{"value" => variant_id}, socket),
    do:
      {:noreply,
       assign(socket, :changeset, maybe_select_variant(socket, variant_id))}

  def handle_event(
        "check_option",
        %{
          "value" => _on_checked,
          "option_group_id" => option_group_id,
          "option_id" => option_id
        },
        socket
      ) do
    changeset =
      maybe_check_option(
        :multiple,
        :check,
        socket,
        option_group_id,
        option_id,
        fn options, option_id ->
          options ++ [option_id]
        end
      )

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "check_option",
        %{"option_group_id" => option_group_id, "option_id" => option_id},
        socket
      ) do
    changeset =
      maybe_check_option(
        :multiple,
        :uncheck,
        socket,
        option_group_id,
        option_id,
        fn options, option_id ->
          options -- [option_id]
        end
      )

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event(
        "choose_option",
        %{"value" => option_id, "option_group_id" => option_group_id},
        socket
      ) do
    changeset =
      maybe_check_option(
        :single,
        :check,
        socket,
        option_group_id,
        option_id,
        fn _options, option_id -> option_id end
      )

    {:noreply, assign(socket, :changeset, changeset)}
  end

  @impl true
  def handle_event("add_to_order", _params, socket) do
    %{changeset: %Ecto.Changeset{} = changeset} = socket.assigns

    socket =
      case valid_form?(changeset) do
        true ->
          %{cart: %Cart{} = cart} = socket.assigns

          %Cart{} = cart = Checkout.add_to_order(cart, %{some: "value"})

          IO.puts("ADD ORDER_ITEM TO CART")

          assign(socket, :cart, cart)

        false ->
          socket
      end

    {:noreply, socket}
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

  def render_option_group_info(%CatalogueItemOptionGroup{
        mandatory: mandatory,
        multiple_selection: false
      }) do
    gettext("Choose %{amount} of the folowing", amount: 1)
    |> maybe_append_required(mandatory)
  end

  def render_option_group_info(%CatalogueItemOptionGroup{
        mandatory: mandatory,
        max_selection: max_selection,
        multiple_selection: true
      }) do
    gettext("Choose %{amount} of the folowing", amount: max_selection)
    |> maybe_append_required(mandatory)
  end

  defp maybe_append_required(msg, false), do: msg
  defp maybe_append_required(msg, true), do: "#{msg} (#{gettext("Required")})"

  # ----------------------------------------------------------------------------
  # Private functions
  #

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
    |> maybe_assign_catalogue(catalogue_id)
    |> maybe_assign_catalogue_item(catalogue_item_id)
    |> maybe_assign_order_item()
    |> assign_cart_path(brand_slug, shop_slug, catalogue_id, catalogue_item_id)
    |> maybe_assign_photos_sources()
    |> assign_nav_title()
  end

  defp apply_action(socket, :cart, %{
         "brand" => brand_slug,
         "shop" => shop_slug,
         "catalogue" => catalogue_id,
         "item" => catalogue_item_id
       }) do
    socket
    |> assign(:page_title, gettext("[Cart]"))
    |> assign(
      :return_to,
      Routes.checkout_catalogue_item_path(
        socket,
        :index,
        brand_slug,
        shop_slug,
        catalogue_id,
        catalogue_item_id
      )
    )
    |> maybe_assign_catalogue(catalogue_id)
    |> maybe_assign_catalogue_item(catalogue_item_id)
    |> maybe_assign_order_item()
    |> assign(:cart_path, "#")
    |> maybe_assign_photos_sources()
    |> assign_nav_title()
  end

  defp assign_cart_path(
         socket,
         brand_slug,
         shop_slug,
         catalogue_id,
         catalogue_item_id
       ) do
    cart_path =
      Routes.checkout_catalogue_item_path(
        socket,
        :cart,
        brand_slug,
        shop_slug,
        catalogue_id,
        catalogue_item_id
      )

    assign(socket, :cart_path, cart_path)
  end

  defp maybe_assign_order_item(socket),
    do:
      maybe_assign(
        socket,
        :order_item,
        fn socket -> assign_order_item(socket) end
      )

  defp assign_order_item(socket) do
    %{
      catalogue_item: %CatalogueItem{
        id: catalogue_item_id,
        option_groups: option_groups,
        variants: variants
      }
    } = socket.assigns

    %OrderItem{} =
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
        option_groups: assign_option_groups(option_groups),
        price: ExCommerceNumeric.format_price(0)
      })
    )
  end

  defp maybe_assign_photos_sources(socket),
    do:
      maybe_assign(socket, :item_photo_source, fn socket ->
        assign_photos_sources(socket)
      end)

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
                                               mandatory: mandatory,
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

      Map.put(acc, option_group_id, %{
        "valid?" => !mandatory,
        "value" => initial_value
      })
    end)
  end

  defp maybe_assign_catalogue(socket, catalogue_id),
    do:
      maybe_assign(
        socket,
        :catalogue,
        fn socket -> assign_catalogue(socket, catalogue_id) end
      )

  defp assign_catalogue(socket, catalogue_id),
    do: assign_catalogue_by_id_or_redirect(socket, catalogue_id)

  defp maybe_assign_catalogue_item(socket, catalogue_item_id),
    do:
      maybe_assign(socket, :catalogue_item, fn socket ->
        assign_catalogue_item(socket, catalogue_item_id)
      end)

  defp assign_catalogue_item(socket, catalogue_item_id),
    do: assign_catalogue_item_by_id_or_redirect(socket, catalogue_item_id)

  defp assign_nav_title(socket), do: assign(socket, :nav_title, gettext("Back"))

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

  defp get_total_price(%Ecto.Changeset{changes: changes, data: data} = cs) do
    variant_price = get_variant_price(changes, data)
    option_groups_price = get_option_groups_price(cs)
    %{quantity: quantity} = changes

    ExCommerceNumeric.add(variant_price, option_groups_price)
    |> ExCommerceNumeric.mult(quantity)
    |> get_price()
  end

  defp get_variant_price(changes, %OrderItem{variants: variants}) do
    case Map.get(changes, :variant_id) do
      nil ->
        0

      variant_id ->
        %CatalogueItemVariant{price: price} =
          Enum.find(variants, fn %CatalogueItemVariant{id: id} ->
            id == variant_id
          end)

        price
    end
  end

  defp get_option_groups_price(%Ecto.Changeset{
         changes: %{option_groups: ogs},
         data: %OrderItem{available_option_groups: aogs}
       }) do
    Enum.reduce(
      aogs.values,
      ExCommerceNumeric.format_price(0),
      fn %CatalogueItemOptionGroup{id: id} = og, acc ->
        get_total_option_group_price(
          Map.fetch!(ogs, id)["value"],
          og
        )
        |> ExCommerceNumeric.add(acc)
      end
    )
  end

  defp get_option_groups_price(%Ecto.Changeset{}),
    do: ExCommerceNumeric.format_price(0)

  defp get_total_option_group_price([], %CatalogueItemOptionGroup{}),
    do: ExCommerceNumeric.format_price(0)

  defp get_total_option_group_price(option_ids, %CatalogueItemOptionGroup{
         options: options
       })
       when is_list(option_ids) do
    Enum.reduce(
      options,
      ExCommerceNumeric.format_price(0),
      fn %CatalogueItemOption{
           id: id,
           catalogue_item_variant: %CatalogueItemVariant{price: price},
           price_modifier: price_modifier
         },
         acc ->
        case id in option_ids do
          true ->
            ExCommerceNumeric.add(
              acc,
              CatalogueItemOption.apply_discount(price, price_modifier)
            )

          false ->
            acc
        end
      end
    )
  end

  defp get_total_option_group_price(nil, %CatalogueItemOptionGroup{}),
    do: ExCommerceNumeric.format_price(0)

  defp get_total_option_group_price(option_id, %CatalogueItemOptionGroup{
         options: options
       })
       when is_binary(option_id) do
    %CatalogueItemOption{
      catalogue_item_variant: %CatalogueItemVariant{price: price},
      price_modifier: price_modifier
    } =
      Enum.find(options, 0, fn %CatalogueItemOption{id: id} ->
        option_id == id
      end)

    CatalogueItemOption.apply_discount(price, price_modifier)
  end

  # ----------------------------------------------------------------------------
  # Changeset Getters
  #

  defp get_quantity(%Ecto.Changeset{changes: %{quantity: quantity}}),
    do: quantity

  defp get_option_group_rules(%Ecto.Changeset{data: data}, option_group_id) do
    case Enum.find(
           data.available_option_groups.rules,
           &(&1.id == option_group_id)
         ) do
      nil ->
        {:error, :option_group_not_found}

      rules ->
        {:ok, rules}
    end
  end

  # ----------------------------------------------------------------------------
  # Changeset Validations
  #

  defp variant_selected?(%Ecto.Changeset{changes: changes}, variant_id),
    do: Map.get(changes, :variant_id) == variant_id

  defp option_checked?(
         :single,
         %Ecto.Changeset{changes: changes},
         option_group_id,
         option_id
       )
       when is_map_key(changes, :option_groups) do
    Map.get(changes.option_groups, option_group_id, %{"value" => nil})
    |> Map.get("value") == option_id
  end

  defp option_checked?(:single, %Ecto.Changeset{}, _og_id, _o_id), do: false

  defp option_checked?(
         :multiple,
         %Ecto.Changeset{changes: changes},
         option_group_id,
         option_id
       )
       when is_map_key(changes, :option_groups),
       do:
         Map.get(changes.option_groups, option_group_id, %{"value" => []})
         |> Map.get("value")
         |> Enum.member?(option_id)

  defp option_checked?(:multiple, %Ecto.Changeset{}, _og_id, _o_id), do: false

  defp option_exists?(rules, option_id),
    do: Enum.find(rules.available_options, fn id -> id == option_id end) !== nil

  defp max_selection_reached?(
         :single,
         _action,
         _changes,
         _rules,
         _option_group_id
       ),
       do: false

  defp max_selection_reached?(
         :multiple,
         :uncheck,
         _changes,
         _rules,
         _option_group_id
       ),
       do: false

  defp max_selection_reached?(
         :multiple,
         :check,
         changes,
         rules,
         option_group_id
       ) do
    %{max_selection: max_selection} = rules

    options_length =
      Map.fetch!(changes, :option_groups)
      |> Map.get(option_group_id, %{"value" => []})
      |> Map.fetch!("value")
      |> length()

    options_length + 1 > max_selection
  end

  defp multiple_select_disabled?(changeset, option_group_id, option_id) do
    case get_option_group_rules(changeset, option_group_id) do
      {:error, :option_group_not_found} ->
        true

      {:ok, rules} ->
        %{max_selection: max_selection} = rules

        options =
          Map.get(changeset.changes, :option_groups, %{
            option_group_id => %{"value" => []}
          })
          |> Map.fetch!(option_group_id)
          |> Map.fetch!("value")

        length(options) >= max_selection && !Enum.member?(options, option_id)
    end
  end

  defp valid_form?(%Ecto.Changeset{valid?: valid?} = changeset) do
    Enum.all?(
      [valid?] ++
        [valid_quantity?(changeset)] ++ [valid_option_groups?(changeset)]
    )
  end

  defp valid_option_groups?(%Ecto.Changeset{changes: %{option_groups: ogs}}),
    do:
      Enum.all?(ogs, fn {_option_group_id, %{"valid?" => valid?}} -> valid? end)

  defp valid_option_groups?(%Ecto.Changeset{}), do: true

  defp valid_quantity?(%Ecto.Changeset{changes: %{quantity: quantity}}),
    do: quantity >= 1

  # ----------------------------------------------------------------------------
  # Changeset Modifiers
  #

  defp maybe_select_variant(socket, variant_id) do
    %{
      changeset: %Ecto.Changeset{changes: changes} = changeset,
      order_item: %OrderItem{variants: variants} = order_item
    } = socket.assigns

    case Enum.member?(Enum.map(variants, & &1.id), variant_id) do
      true ->
        Checkout.change_order_item(
          order_item,
          Map.merge(changes, %{variant_id: variant_id, price: 10})
        )
        |> Map.put(:action, :validate)

      false ->
        changeset
    end
  end

  defp maybe_check_option(
         type,
         action,
         socket,
         option_group_id,
         option_id,
         check_fun
       ) do
    %{
      changeset: %Ecto.Changeset{changes: changes} = changeset,
      order_item: %OrderItem{} = order_item
    } = socket.assigns

    with {:ok, rules} <- get_option_group_rules(changeset, option_group_id),
         true <- option_exists?(rules, option_id),
         false <-
           max_selection_reached?(
             type,
             action,
             changes,
             rules,
             option_group_id
           ) do
      option_groups = Map.fetch!(changes, :option_groups)

      new_value =
        Map.fetch!(option_groups, option_group_id)
        |> Map.fetch!("value")
        |> check_fun.(option_id)

      Checkout.change_order_item(
        order_item,
        Map.merge(changes, %{
          option_groups:
            Map.put(
              option_groups,
              option_group_id,
              validate_option(type, new_value, rules.mandatory)
            )
        })
      )
      |> Map.put(:action, :validate)
    else
      _error ->
        changeset
    end
  end

  defp validate_option(:multiple, [] = value, true),
    do: %{"valid?" => false, "value" => value}

  defp validate_option(:single, value, true) when is_nil(value),
    do: %{"valid?" => false, "value" => value}

  defp validate_option(_type, value, true),
    do: %{"valid?" => true, "value" => value}

  defp validate_option(_type, value, false),
    do: %{"valid?" => true, "value" => value}
end
