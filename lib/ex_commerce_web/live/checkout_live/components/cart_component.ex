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
    {:ok, assign(socket, :order_items, get_order_items(assigns.opts))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <div class="px-4">
        <.title_bar title={gettext("Order")} />
      </div>

      <div class="px-6 py-2">
        <div class="lg:grid">
          <%= if @order_items == [] do %>
            <.render_empty_cart />
          <% else %>
            <%= for %Cart.OrderItem{
              catalogue_item: %CatalogueItem{name: name, photos: photos},
              quantity: quantity,
              price: price,
              variant: %CatalogueItemVariant{type: variant_type},
              temp_id: temp_id
            } <- @order_items do %>
              <.render_order_item
                name={name}
                price={price}
                quantity={quantity}
                temp_id={temp_id}
                variant_type={variant_type}
              >
                <:photos>
                  <%= for photo <- get_photos(photos, [
                    use_placeholder: true,
                    type: :avatar
                  ]) do %>
                    <%= render_image([
                      source: get_photo_source(@socket, photo),
                      size_classes: "w-16 sm:w-20 md:w-24 lg:w-28 xl:w-32 h-16 sm:h-20 md:h-24 lg:h-28 xl:h-32"
                    ]) %>
                  <% end %>
                </:photos>
              </.render_order_item>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp render_empty_cart(assigns) do
    ~H"""
    <div class="flex flex-col items-center">
      <.icon
        outlined={true}
        name={:shopping_cart}
        class="text-gray-400 w-16 h-16 my-8"
      />
      <span class="text-lg text-gray-500"><%= gettext("The cart is empty") %></span>
    </div>
    """
  end

  defp render_order_item(assigns) do
    ~H"""
    <div class="lg:col-span-1 flex sm:-ml-4 md:-ml-8 lg:-ml-4 xl:-ml-8 2xl:-ml-12 3xl:-ml-16">
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
            <%= render_slot(@photos) %>
          </div>
        </div>
        <div class="
          col-span-10 lg:col-span-9 row-span-3
          sm:ml-4 md:ml-8 lg:-ml-4 xl:-ml-8 2xl:-ml-12 3xl:-ml-20
          -mr-8 sm:-mr-8 md:-mr-8 lg:-mr-12 xl:-mr-16 2xl:-mr-16 3xl:-mr-20
          flex flex-col justify-between
        ">
          <div class="">
            <p class="
              text-base text-black font-medium
              text-ellipsis overflow-hidden whitespace-nowrap
            ">
            (<%= @quantity %>) <%= @name %>
            </p>
          </div>
          <div class="">
            <p class="
              text-base text-gray-700 font-normal
              text-ellipsis overflow-hidden whitespace-nowrap
            ">
              <%= @variant_type %>
            </p>
          </div>
          <div class="flex flex-row justify-between items-center">
            <div class="self-center">
              <p class="
                tracking-wider font-bold text-xl text-sky-600
                text-ellipsis overflow-hidden whitespace-nowrap
              ">
                $<%= @price %>
              </p>
            </div>
            <div class="justify-self-end self-center">
              <.custom_link
                to={"#"}
                class="rounded-xl"
                phx-click="remove_order_item"
                phx-value-remove={@temp_id}
                data={[confirm: gettext("Delete from order?")]}
              >
                <.pill bgcolor={"bg-white"} textcolor="text-sky-600"
                  outlined
                  class="text-base px-2 pressable"
                >
                  <%= gettext("Remove") %>
                </.pill>
              </.custom_link>
            </div>
          </div>
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
