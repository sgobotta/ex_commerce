defmodule ExCommerceWeb.AdminDashboardLive do
  @moduledoc false

  use ExCommerceWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{})}
  end
end
