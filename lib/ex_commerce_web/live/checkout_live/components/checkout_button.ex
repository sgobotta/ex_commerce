defmodule ExCommerceWeb.CheckoutLive.Components.CheckoutButton do
  @moduledoc """
  Component to display the Checkout button
  """

  use ExCommerceWeb, :live_component

  @impl true
  def update(%{} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  @impl true
  def render(assigns) do
    case assigns.enabled do
      true ->
        render_button(assigns)

      false ->
        render_placeholder_button(assigns)
    end
  end

  defp render_button(assigns) do
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
      <%= render_slot(@enabled_content) %>
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
      <%= render_slot(@disabled_content) %>
    </div>
    """
  end
end
