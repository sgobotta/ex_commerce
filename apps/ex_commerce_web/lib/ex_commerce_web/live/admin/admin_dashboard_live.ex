defmodule ExCommerceWeb.AdminDashboardLive do
  @moduledoc false

  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        %{assigns: %{user: user}} =
          socket = assign_defaults(socket, params, session)

        {:ok, assign(socket, :user, user)}

      false ->
        {:ok, socket}
    end
  end
end
