defmodule ExCommerceWeb.PlaceLive.Search do
  @moduledoc """
  Searchs for places
  """

  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_public_defaults(params, session)}

      false ->
        {:ok, socket}
    end
  end
end
