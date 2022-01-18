defmodule ExCommerceWeb.BrandLive.PublicShow do
  @moduledoc """
  Shows a single public brand
  """

  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brand_by_slug_or_redirect(params)}

      false ->
        {:ok, socket}
    end
  end
end
