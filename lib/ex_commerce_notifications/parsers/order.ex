defmodule ExCommerceNotifications.Parsers.Order do
  @moduledoc """
  Convenience module to break down an #{ExCommerce.Checkout.Cart.Order} struct
  in order to render messages for notifications.
  """

  alias ExCommerce.Checkout.Cart

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  import ExCommerceNumeric

  @doc """
  Given an `#{Order} struct returns a map with relevant order fields.
  """
  @spec parse(Cart.Order.t()) :: map()
  def parse(%Cart.Order{
        address: address,
        buyer_name: buyer_name,
        note: note,
        order_items: order_items,
        price: price
      }) do
    %{
      address: address,
      buyer_name: buyer_name,
      items: parse_order_items(order_items),
      note: note,
      price: price
    }
  end

  defp parse_order_items(order_items) do
    Enum.map(order_items, fn %Cart.OrderItem{
                               catalogue_item: %CatalogueItem{
                                 name: name
                               },
                               price: order_item_price,
                               quantity: quantity,
                               variant: %CatalogueItemVariant{
                                 type: type,
                                 price: variant_price
                               }
                             } = order_item ->
      order_item_price = format_price(order_item_price)
      variant_price = format_price(variant_price)

      %{
        name: name,
        quantity: quantity,
        variant: type,
        variant_price: variant_price,
        total_price: order_item_price,
        option_groups: parse_option_groups(order_item)
      }
    end)
  end

  defp parse_option_groups(%Cart.OrderItem{
         available_option_groups: %{
           values: available_option_groups
         },
         option_groups: option_groups
       }) do
    Enum.reduce(option_groups, [], fn option_group, acc ->
      case parse_option_group(option_group, available_option_groups) do
        nil ->
          acc

        option_group ->
          acc ++ [option_group]
      end
    end)
  end

  defp parse_option_group(
         {_catalogue_option_group, %{"value" => []}},
         _available_option_groups
       ),
       do: nil

  defp parse_option_group(
         {_catalogue_option_group, %{"value" => ""}},
         _available_option_groups
       ),
       do: nil

  defp parse_option_group(
         {catalogue_option_group, %{"value" => values}},
         available_option_groups
       )
       when is_list(values) do
    %CatalogueItemOptionGroup{
      name: name,
      options: options
    } = find_group(available_option_groups, catalogue_option_group)

    catalogue_item_options =
      Enum.filter(options, fn %CatalogueItemOption{id: id} ->
        id in values
      end)

    options = parse_catalogue_item_options(catalogue_item_options)

    %{name: name, options: options}
  end

  defp parse_option_group(
         {catalogue_option_group, %{"value" => value}},
         available_option_groups
       )
       when is_binary(value) do
    %CatalogueItemOptionGroup{
      name: name,
      options: options
    } = find_group(available_option_groups, catalogue_option_group)

    %CatalogueItemOption{} =
      catalogue_item_option =
      Enum.find(options, fn %CatalogueItemOption{id: id} ->
        id == value
      end)

    options = parse_catalogue_item_options([catalogue_item_option])

    %{name: name, options: options}
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

  defp find_group(available_option_groups, option_group_id) do
    Enum.find(available_option_groups, fn %CatalogueItemOptionGroup{
                                            id: id
                                          } ->
      id == option_group_id
    end)
  end
end
