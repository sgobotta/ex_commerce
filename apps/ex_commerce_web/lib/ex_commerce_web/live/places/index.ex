defmodule ExCommerceWeb.PlaceLive.Index do
  @moduledoc """
  Lists places
  """

  use ExCommerceWeb, :live_view

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brands()}

      false ->
        {:ok, socket}
    end
  end
end
