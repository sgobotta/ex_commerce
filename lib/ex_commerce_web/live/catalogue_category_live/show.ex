defmodule ExCommerceWeb.CatalogueCategoryLive.Show do
  @moduledoc """
  Shows a single catalogue category
  """
  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_main_dashboard.html"}
  }

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brand_or_redirect(params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(
        %{"catalogue_category_id" => _catalogue_category_id} = params,
        _url,
        socket
      ) do
    case connected?(socket) do
      true ->
        {:noreply,
         socket
         |> assign(:page_title, page_title(socket.assigns.live_action))
         |> assign_catalogue_category_or_redirect(params, %{})}

      false ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: gettext("Show Catalogue category")
  defp page_title(:edit), do: gettext("Edit Catalogue category")
end
