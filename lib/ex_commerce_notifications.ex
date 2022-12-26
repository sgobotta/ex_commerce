defmodule ExCommerceNotifications do
  @moduledoc """
  `ExCommerceNotifications` is a convenience modules group to handle different
  ways of parsing and sending messages or notifications.
  """

  alias ExCommerce.Checkout.{Cart, Embeds}

  alias ExCommerceNotifications.Parsers

  @doc """
  Given a message type and a `#{Cart}` struct returns a message that rerpesents
  an order.
  """
  @spec get_order_message(atom(), Cart.t()) :: String.t()
  def get_order_message(:whatsapp, %Cart{} = cart) do
    %Embeds.Order{} = order = Cart.get_order(cart)

    %{
      address: address,
      note: note,
      items: order_items,
      price: price
    } = Parsers.Order.parse(order)

    order_items = render_items(order_items)

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

  defp render_items(items) do
    Enum.reduce(items, "", fn item, acc ->
      option_groups_msg = render_groups(item.option_groups)
      items_msg = render_item(item)

      acc <>
        """
        #{items_msg}
        #{option_groups_msg}
        """
    end)
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

  defp render_groups(groups) do
    Enum.reduce(groups, "", fn parsed_group, acc ->
      acc <> render_group(parsed_group)
    end)
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
