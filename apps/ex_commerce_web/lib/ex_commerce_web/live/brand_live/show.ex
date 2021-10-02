defmodule ExCommerceWeb.BrandLive.Show do
  @moduledoc """
  Shows a single brand
  """
  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok, assign_defaults(socket, params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"brand_id" => _brand_id} = params, _session, socket) do
    case connected?(socket) do
      true ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign_brand_or_redirect(params, %{})}

      false ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: gettext("Show Brand")
  defp page_title(:edit), do: gettext("Edit Brand")
end
