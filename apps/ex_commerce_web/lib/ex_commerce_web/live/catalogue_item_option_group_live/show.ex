defmodule ExCommerceWeb.CatalogueItemOptionGroupLive.Show do
  @moduledoc """
  Shows a single catalogue item option group
  """
  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(:redirect_to, params["redirect_to"])
         |> assign_defaults(params, session)
         |> assign_brand_or_redirect(params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(
        %{"catalogue_item_option_group_id" => _catalogue_item_option_group_id} =
          params,
        _url,
        socket
      ) do
    case connected?(socket) do
      true ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign_catalogue_item_option_group_or_redirect(params, %{})}

      false ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Catalogue item option group"
  defp page_title(:edit), do: "Edit Catalogue item option group"
end
