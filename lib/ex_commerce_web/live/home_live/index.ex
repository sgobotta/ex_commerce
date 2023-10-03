defmodule ExCommerceWeb.HomeLive.Index do
  @moduledoc false

  use ExCommerceWeb,
      {:live_view, layout: {ExCommerceWeb.LayoutView, :live_home}}

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok, assign_defaults(socket, params, session)}

      false ->
        {:ok, socket}
    end
  end
end
