defmodule ExCommerceWeb.AdminDashboardLive do
  @moduledoc false

  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    socket = assign_params(params, socket)

    case connected?(socket) do
      true ->
        %{assigns: %{user: user}} =
          socket = assign_defaults(socket, params, session)

        {:ok, assign(socket, :user, user)}

      false ->
        {:ok, socket}
    end
  end

  defp assign_params(%{"brand" => brand}, socket) do
    socket
    |> assign(:brand, brand)
  end

  defp assign_params(params, socket) do
    # Find and assign the default brand
    socket
    |> assign(:brand, "12")
  end
end
