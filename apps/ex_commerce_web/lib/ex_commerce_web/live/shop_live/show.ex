defmodule ExCommerceWeb.ShopLive.Show do
  @moduledoc """
  Shows a single shop
  """

  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        %{assigns: %{user: user}} =
          socket = assign_defaults(socket, params, session)

        socket = assign_brand(socket, params, session)

        {:ok,
         socket
         |> assign(:user, user)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:shop, Marketplaces.get_shop!(id))}
  end

  defp page_title(:show), do: "Show Shop"
  defp page_title(:edit), do: "Edit Shop"
end
