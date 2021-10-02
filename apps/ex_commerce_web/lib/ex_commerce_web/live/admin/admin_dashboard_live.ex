defmodule ExCommerceWeb.AdminDashboardLive do
  @moduledoc false

  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brand(params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"brand" => _brand_id} = params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> redirect(to: Routes.brand_index_path(socket, :index))}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Home"))
  end
end
