defmodule ExCommerceWeb.CheckoutLive.Components.CheckoutButton do
  @moduledoc """
  Component to display the Checkout button
  """

  use ExCommerceWeb, :live_component

  alias ExCommerce.Checkout
  alias ExCommerce.Checkout.Cart

  @impl true
  def update(%{} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    %{cart: %Cart{} = cart} = assigns

    case valid_checkout?(cart) do
      true ->
        render_button(cart, assigns)

      false ->
        render_placeholder_button(assigns)
    end
  end

  defp render_button(%Cart{} = cart, assigns) do
    ~H"""
    <button class="
      flex justify-center rounded-lg py-2 bg-green-400
      w-full sm:w-1/2
      cursor-pointer shadow-button
      transition-transform ease-in-out duration-100
      active:scale-90 active:shadow-lg
      hover:bg-green-300
    "
      tabindex="0"
      phx-click="checkout_order"
    >
      <div class="flex flex-row">
        <div class="px-2">
          <p class="font-medium text-white">
            (<%= get_order_items(cart) %>)
          </p>
        </div>
        <div class="px-2">
          <p class="font-medium text-white">
            <%= get_order_price(cart) %>
          </p>
        </div>
        <div class="px-2">
          <p class="font-medium text-white">
            <%= gettext("Checkout") %>
          </p>
        </div>
        <div class="pt-1">
          <.icon name={:shopping_bag} outlined class="
            text-white
            flex-shrink-0 h-7 w-7
          "/>
        </div>
      </div>
    </button>
    """
  end

  defp render_placeholder_button(assigns) do
    ~H"""
    <div class="
      flex justify-center rounded-lg py-2 bg-gray-400
      w-full sm:w-1/2
      cursor-not-allowed shadow-button
    ">
      <div class="flex flex-row">
        <div class="px-2">
          <p class="font-medium text-white text-center">
            <%= gettext("Add products to your order") %>
          </p>
        </div>
        <div class="pt-1 self-center">
          <.icon name={:shopping_bag} outlined class="
            pr-2
            text-white
            flex-shrink-0 h-7 w-7
          "/>
        </div>
      </div>
    </div>
    """
  end

  defp valid_checkout?(%Cart{} = cart) do
    Checkout.valid_checkout?(cart)
  end

  defp get_order_items(%Cart{} = cart) do
    Checkout.get_order_items(cart)
  end

  defp get_order_price(%Cart{} = cart) do
    price = Checkout.get_order_price(cart)
    "$#{price}"
  end
end
