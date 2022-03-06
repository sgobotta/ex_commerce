defmodule ExCommerceWeb.PlaceLive.Show do
  @moduledoc """
  Shows a single places
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, "live_places.html"}
  }

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_place_by_slug_or_redirect(params)}

      false ->
        {:ok, socket}
    end
  end
end
