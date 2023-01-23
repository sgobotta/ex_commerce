defmodule ExCommerceWeb.HomeLive.Index do
  @moduledoc false

  use ExCommerceWeb,
      {:live_view, layout: {ExCommerceWeb.LayoutView, :live_home}}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
