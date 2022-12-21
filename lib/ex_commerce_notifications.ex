defmodule ExCommerceNotifications do
  @moduledoc """
  `ExCommerceNotifications` is a convenience modules group to handle different
  ways of parsing and sending messages or notifications.
  """

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  alias ExCommerce.Checkout.{Cart, Order, OrderItem}

  alias ExCommerceNotifications.Parsers

  import ExCommerceNumeric

  def get_order_message(:whatsapp, %Cart{} = cart, price) do
    %Order{order_items: order_items} = order = Cart.get_order(cart)

    %{
      address: address,
      note: note,
      items: _order_items
    } = Parsers.Order.parse(order)

    order_items =
      Enum.reduce(order_items, "", fn %OrderItem{
                                        catalogue_item: %CatalogueItem{
                                          name: name
                                        },
                                        price: order_item_price,
                                        quantity: quantity,
                                        variant: %CatalogueItemVariant{
                                          type: type,
                                          price: variant_price
                                        }
                                      } = order_item,
                                      acc ->
        option_groups = get_option_groups_message(:whatsapp, order_item)

        order_item_price = format_price(order_item_price)
        variant_price = format_price(variant_price)

        item =
          render_item(%{
            quantity: quantity,
            name: name,
            variant: type,
            variant_price: variant_price,
            total_price: order_item_price
          })

        acc <>
          """
          #{item}
          #{option_groups}
          """
      end)

    """
    ```
    🛒 PEDIDO: *#{Ecto.UUID.generate()}*%0A
    %0A
    #{order_items}
    %0A
    💵 Total: *$#{price}*%0A

    🏠 Dirección: *#{address}*%0A
    📝 Notas: _#{note}_
    ```
    """
  end

  defp get_option_groups_message(:whatsapp, %OrderItem{
         available_option_groups: %{
           values: available_option_groups
         },
         option_groups: option_groups
       }) do
    Enum.reduce(option_groups, "", fn
      {_catalogue_option_group, %{"value" => []}}, acc ->
        acc

      {_catalogue_option_group, %{"value" => ""}}, acc ->
        acc

      {catalogue_option_group, %{"value" => values}}, acc
      when is_list(values) ->
        %CatalogueItemOptionGroup{
          name: group_name,
          options: options
        } =
          Enum.find(available_option_groups, fn %CatalogueItemOptionGroup{
                                                  id: id
                                                } ->
            id == catalogue_option_group
          end)

        options =
          Enum.filter(options, fn %CatalogueItemOption{id: id} ->
            id in values
          end)

        options = parse_catalogue_item_options(options)

        acc <> render_group(%{name: group_name, options: options})

      {catalogue_option_group, %{"value" => value}}, acc
      when is_binary(value) ->
        %CatalogueItemOptionGroup{
          name: group_name,
          options: options
        } =
          Enum.find(available_option_groups, fn %CatalogueItemOptionGroup{
                                                  id: id
                                                } ->
            id == catalogue_option_group
          end)

        %CatalogueItemOption{} =
          cio =
          Enum.find(options, fn %CatalogueItemOption{id: id} ->
            id == value
          end)

        options = parse_catalogue_item_options([cio])

        acc <> render_group(%{name: group_name, options: options})
    end)
  end

  defp parse_catalogue_item_options(options) do
    Enum.map(options, fn %CatalogueItemOption{} = cio ->
      parse_catalogue_item_option(cio)
    end)
  end

  defp parse_catalogue_item_option(%CatalogueItemOption{
         catalogue_item_variant: %CatalogueItemVariant{
           catalogue_item: %CatalogueItem{
             name: catalogue_item_name
           },
           price: variant_price,
           type: variant_type
         },
         price_modifier: %Decimal{coef: 0}
       }) do
    variant_price = format_price(variant_price)

    %{
      item_name: catalogue_item_name,
      variant_name: variant_type,
      variant_price: variant_price
    }
  end

  defp parse_catalogue_item_option(
         %CatalogueItemOption{
           catalogue_item_variant: %CatalogueItemVariant{
             catalogue_item: %CatalogueItem{
               name: catalogue_item_name
             },
             price: variant_price,
             type: variant_type
           },
           price_modifier: %Decimal{}
         } = cio
       ) do
    variant_price = format_price(variant_price)

    discount_price =
      CatalogueItemOption.get_discount_price(cio)
      |> format_price()

    %{
      item_name: catalogue_item_name,
      variant_name: variant_type,
      variant_price: variant_price,
      discount_price: discount_price
    }
  end

  defp render_item(%{
         quantity: quantity,
         name: name,
         variant: type,
         variant_price: variant_price,
         total_price: order_item_price
       }) do
    """
    ▪ (*#{quantity}*) #{name}, #{type} ... _$#{variant_price}_ (u) *$#{order_item_price}*%0A
    """
  end

  defp render_group(%{name: group_name, options: options}) do
    options =
      Enum.reduce(options, "", fn parsed_option, acc ->
        acc <> render_option(parsed_option)
      end)

    """
    %20%20*#{group_name}*:%0A
    #{options}
    """
  end

  defp render_option(%{
         item_name: item_name,
         variant_name: variant_name,
         variant_price: variant_price,
         discount_price: discount_price
       }) do
    """
    %20%20%20%20▫ #{item_name}, #{variant_name} ... ~$#{variant_price}~ $#{discount_price}%0A
    """
  end

  defp render_option(%{
         item_name: item_name,
         variant_name: variant_name,
         variant_price: variant_price
       }) do
    """
    %20%20%20%20▫ #{item_name}, #{variant_name} ... $#{variant_price}%0A
    """
  end
end
