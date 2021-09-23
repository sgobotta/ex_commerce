defmodule ExCommerceWeb.BrandLive.Show do
  @moduledoc """
  Shows a single brand
  """
  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        %{assigns: %{user: user}} =
          socket = assign_defaults(socket, params, session)

        {:ok,
         socket
         |> assign(:user, user)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:brand, Marketplaces.get_brand!(id))}
  end

  defp page_title(:show), do: "Show Brand"
  defp page_title(:edit), do: "Edit Brand"
end
