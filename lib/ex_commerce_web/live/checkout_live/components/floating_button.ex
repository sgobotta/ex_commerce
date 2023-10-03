defmodule ExCommerceWeb.CheckoutLive.Components.FloatingButton do
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
      w-full md:w-1/2
      cursor-pointer shadow-button-sm
      transition duration-300
      hover:bg-green-300 hover:shadow-button-sm
      active:scale-98 active:shadow-button-xs
      with-outline-sm gray
    "
      tabindex="0"
      phx-click={@on_click_event}
    >
      <%= render_slot(@enabled_content) %>
    </button>
    """
  end

  defp render_placeholder_button(assigns) do
    ~H"""
    <div class="
      flex justify-center rounded-lg py-2 bg-gray-400
      w-full md:w-1/2
      cursor-not-allowed shadow-button
    ">
      <%= render_slot(@disabled_content) %>
    </div>
    """
  end
end
