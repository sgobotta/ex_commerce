defmodule ExCommerceWeb.CheckoutLive.Components.CartComponent do
  @moduledoc """
  Component to display the current Cart status
  """

  use ExCommerceWeb, :live_component

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.Checkout.Cart
  alias ExCommerce.Offerings.{CatalogueItem, CatalogueItemVariant}

  @impl true
  def update(%{} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <div class="px-4">
        <.title_bar title="Order Items" />
      </div>

      <div class="px-6 py-2">
        <div class="lg:grid">
          <%= render_order_items(get_order_items(@opts), assigns) %>
        </div>
      </div>
    </div>
    """
  end

  defp render_order_items([], assigns) do
    ~H"""
    <%= gettext("The cart is empty") %>
    """
  end

  defp render_order_items(order_items, assigns) do
    ~H"""
    <%= for %Cart.OrderItem{} = order_item <- order_items do %>
      <%= render_order_item(order_item, assigns) %>
    <% end %>
    """
  end

  defp render_order_item(
         %Cart.OrderItem{
           catalogue_item: %CatalogueItem{name: name, photos: photos},
           quantity: quantity,
           price: price,
           variant: %CatalogueItemVariant{type: type},
           temp_id: temp_id
         },
         assigns
       ) do
    ~H"""
    <div class="lg:col-span-1 flex">
      <div class="basis-1/12 self-center">
      </div>
      <div class="
        basis-11/12 lg:basis-10/12
        grid grid-cols-12 grid-rows-3
        bg-gray-300 rounded-md mb-2 p-2 sm:p-4
      ">
        <div class="
          relative col-span-1 lg:col-span-2 row-span-3 self-center
          w-16 sm:w-20 md:w-24 lg:w-28 xl:w-32
          h-16 sm:h-20 md:h-24 lg:h-28 xl:h-32
        ">
          <div class="absolute -left-10 lg:-left-16">
            <%= for photo <- get_photos(photos, [
              use_placeholder: true,
              type: :avatar
            ]) do %>
              <%= render_image([
                source: get_photo_source(@socket, photo),
                size_classes: "w-16 sm:w-20 md:w-24 lg:w-28 xl:w-32 h-16 sm:h-20 md:h-24 lg:h-28 xl:h-32"
              ]) %>
            <% end %>
          </div>
        </div>
        <div class="col-span-10 lg:col-span-9 row-span-1">
          <p class="
            text-xl text-black font-medium
            text-ellipsis overflow-hidden whitespace-nowrap
          ">
          (<%= quantity %>) <%= name %>
          </p>
        </div>
        <div class="col-span-10 lg:col-span-9 row-span-1">
          <p class="
            text-base text-gray-700
            text-ellipsis overflow-hidden whitespace-nowrap
          ">
            <%= type %>
          </p>
        </div>
        <div class="col-span-5 lg:col-span-5 row-span-1 self-center">
          <p class="
            tracking-wider font-bold text-xl text-sky-600
            text-ellipsis overflow-hidden whitespace-nowrap
          ">
            $<%= price %>
          </p>
        </div>
        <div class="
          col-span-6 lg:col-span-5 row-span-1
          justify-self-end self-center
        ">
          <.link
            to={"#"}
            class="rounded-xl"
            phx-click="remove_order_item"
            phx-value-remove={temp_id}
            data={[confirm: gettext("Delete from order?")]}
          >
            <.pill bgcolor={"bg-white"} textcolor="text-sky-600"
              outlined
              class="text-base px-2 pressable"
            >
              <%= gettext("Remove") %>
            </.pill>
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp get_order_items(%{
         cart: %Cart{order: %Cart.Order{order_items: order_items}}
       }),
       do: order_items
end
