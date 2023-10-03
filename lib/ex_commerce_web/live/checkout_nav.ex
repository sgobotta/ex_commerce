defmodule ExCommerceWeb.CheckoutNav do
  @moduledoc false

  import Phoenix.LiveView
  import Phoenix.Component

  alias ExCommerce.Checkout.Cart

  def on_mount(:check_action, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:expanded, :handle_params, &handle_expanded_params/3)}
  end

  def on_mount(
        :check_cart,
        %{"catalogue" => catalogue_id},
        %{"_csrf_token" => csrf_token},
        socket
      ) do
    %Cart{} = cart = new_cart(csrf_token, catalogue_id)

    {:cont, assign_cart(socket, cart)}
  end

  def on_mount(:check_cart, _params, _session, socket),
    do: {:cont, assign_cart(socket)}

  @spec maybe_assign_cart(Phoenix.Socket.t(), map(), map()) ::
          Phoenix.Socket.t()
  def maybe_assign_cart(
        %{assigns: %{cart: nil}} = socket,
        %{"catalogue" => catalogue_id},
        %{"_csrf_token" => csrf_token}
      ) do
    socket
    |> assign(:cart, new_cart(csrf_token, catalogue_id))
  end

  def maybe_assign_cart(socket, _params, _session), do: socket

  @spec new_cart(String.t(), String.t()) :: Cart.t()
  defp new_cart(csrf_token, catalogue_id) do
    Cart.generate_id(csrf_token, catalogue_id)
    |> Cart.new()
  end

  defp handle_expanded_params(_params, _url, socket) do
    {:cont, socket}
  end

  defp assign_cart(socket), do: assign_new(socket, :cart, fn -> nil end)

  defp assign_cart(socket, %Cart{} = cart), do: assign(socket, :cart, cart)
end
