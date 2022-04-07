defmodule ExCommerceWeb.AdminNav do
  @moduledoc false

  import Phoenix.LiveView

  alias ExCommerceWeb.{
    BrandLive,
    CatalogueCategoryLive,
    CatalogueItemLive,
    CatalogueItemOptionGroupLive,
    CatalogueLive,
    OverviewLive,
    ShopLive
  }

  def on_mount(:default, _params, _session, socket) do
    {
      :cont,
      socket
      |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)
    }
  end

  defp handle_active_tab_params(_params, _url, socket) do
    active_tab = get_active_tab(socket.view, socket.assigns.live_action)

    {:cont, assign(socket, active_tab: active_tab)}
  end

  defp get_active_tab(BrandLive.Index, _action), do: :brands
  defp get_active_tab(OverviewLive.Index, _action), do: :overview
  defp get_active_tab(ShopLive.Index, _action), do: :shops
  defp get_active_tab(ShopLive.Show, _action), do: :shops
  defp get_active_tab(CatalogueLive.Index, _action), do: :catalogues
  defp get_active_tab(CatalogueLive.Show, _action), do: :catalogues

  defp get_active_tab(CatalogueCategoryLive.Index, _action),
    do: :catalogue_categories

  defp get_active_tab(CatalogueCategoryLive.Show, _action),
    do: :catalogue_categories

  defp get_active_tab(CatalogueItemLive.Index, _action), do: :catalogue_items
  defp get_active_tab(CatalogueItemLive.Show, _action), do: :catalogue_items

  defp get_active_tab(CatalogueItemOptionGroupLive.Index, _action),
    do: :catalogue_item_option_groups

  defp get_active_tab(CatalogueItemOptionGroupLive.Show, _action),
    do: :catalogue_item_option_groups

  defp get_active_tab(_view, _action), do: nil
end
