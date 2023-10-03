defmodule ExCommerceWeb.CheckoutLive.Components.RollingOrder do
  @moduledoc """
  Component that displays the rolling order layout
  """

  use ExCommerceWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full items-center" id={@id}>
      <div class="basis-1/4 flex flex-col w-full justify-center items-center shrink-0"/>
      <div class="flex basis-3/4 w-full justify-center">
        <div class="w-full sm:w-full md:w-10/12 lg:w-10/12 xl:w-2/3">
          <LiveMotion.motion
            id="item-content"
            initial={[y: [1000]]}
            animate={[y: [0]]}
            transition={[]}
            exit={[y: [1000]]}
            class="h-full w-full"
          >
            <div class={"z-50 bg-transparent h-full"}>
              <%= render_slot(@main_slot) %>
            </div>
          </LiveMotion.motion>
        </div>
      </div>
      <%= render_slot(@button_slot) %>
    </div>
    """
  end
end
