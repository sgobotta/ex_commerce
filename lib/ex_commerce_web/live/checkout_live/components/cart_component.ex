defmodule ExCommerceWeb.CheckoutLive.Components.CartComponent do
  @moduledoc """
  Component to display the current Cart status
  """

  use ExCommerceWeb, :live_component

  @impl true
  def update(%{} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
