defmodule ExCommerceNotification do
  @moduledoc """
  `ExCommerceNumeric` is a convenience modules group to handle different ways
  of sending a message or notifications.
  """

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  alias ExCommerce.Checkout.{Cart, Order, OrderItem}

  import ExCommerceNumeric

  def get_order_message(:whatsapp, %Cart{} = cart, price) do
    %Order{address: address, note: note, order_items: order_items} =
      _order = Cart.get_order(cart)

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
        option_groups_message = get_option_groups_message(:whatsapp, order_item)

        acc <>
          """
          ▪ (*#{quantity}*) #{name}, #{type} ... _$#{variant_price}_ (u) *$#{order_item_price}*%0A
          #{option_groups_message}
          """
      end)

    """
    ```
    PEDIDO: *#{Ecto.UUID.generate()}*%0A
    %0A
    #{order_items}
    %0A
    💵 Total: *$#{price}*%0A

    🏠 Dirección: *#{address}*%0A
    📝 Notas: _#{note}_
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
          _catalogue_item_option_group =
          Enum.find(available_option_groups, fn %CatalogueItemOptionGroup{
                                                  id: id
                                                } ->
            id == catalogue_option_group
          end)

        options =
          Enum.filter(options, fn %CatalogueItemOption{id: id} ->
            id in values
          end)

        acc =
          acc <>
            """
            %20%20*#{group_name}*:%0A
            """

        Enum.reduce(options, acc, fn %CatalogueItemOption{
                                       catalogue_item_variant:
                                         %CatalogueItemVariant{
                                           catalogue_item: %CatalogueItem{
                                             name: catalogue_item_name
                                           },
                                           price: variant_price,
                                           type: variant_type
                                         },
                                       price_modifier: price_modifier
                                     },
                                     acc ->
          discount_price =
            format_price(
              Decimal.sub(
                variant_price,
                Decimal.mult(
                  variant_price,
                  Decimal.div(price_modifier, 100)
                )
              )
            )

          acc <>
            """
            %20%20%20%20▫ #{catalogue_item_name}, #{variant_type} ... ~$#{variant_price}~ $#{discount_price}%0A
            """
        end)

      {catalogue_option_group, %{"value" => value}}, acc
      when is_binary(value) ->
        %CatalogueItemOptionGroup{
          name: group_name,
          options: options
        } =
          _catalogue_item_option_group =
          Enum.find(available_option_groups, fn %CatalogueItemOptionGroup{
                                                  id: id
                                                } ->
            id == catalogue_option_group
          end)

        %CatalogueItemOption{
          catalogue_item_variant: %CatalogueItemVariant{
            catalogue_item: %CatalogueItem{
              name: catalogue_item_name
            },
            price: variant_price,
            type: variant_type
          },
          price_modifier: price_modifier
        } =
          Enum.find(options, fn %CatalogueItemOption{id: id} ->
            id == value
          end)

        discount_price =
          format_price(
            Decimal.sub(
              variant_price,
              Decimal.mult(
                variant_price,
                Decimal.div(price_modifier, 100)
              )
            )
          )

        acc <>
          """
          %20%20*#{group_name}*:%0A
          %20%20%20%20▫ #{catalogue_item_name}, #{variant_type} ... ~$#{variant_price}~ $#{discount_price}%0A
          """
    end)
  end
end
