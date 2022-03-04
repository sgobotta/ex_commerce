defmodule ExCommerceWeb.AdminNav do
  @moduledoc false

  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {
      :cont,
      socket
      |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)
    }
  end

  defp handle_active_tab_params(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {ExCommerceWeb.BrandLive.Index, _action} ->
          :brands

        {ExCommerceWeb.HomeLive.Index, _action} ->
          :home

        {ExCommerceWeb.ShopLive.Index, _action} ->
          :shops

        {ExCommerceWeb.ShopLive.Show, _action} ->
          :shops

        {ExCommerceWeb.CatalogueLive.Index, _action} ->
          :catalogues

        {ExCommerceWeb.CatalogueLive.Show, _action} ->
          :catalogues

        {ExCommerceWeb.CatalogueCategoryLive.Index, _action} ->
          :catalogue_categories

        {ExCommerceWeb.CatalogueCategoryLive.Show, _action} ->
          :catalogue_categories

        {ExCommerceWeb.CatalogueItemLive.Index, _action} ->
          :catalogue_items

        {ExCommerceWeb.CatalogueItemLive.Show, _action} ->
          :catalogue_items

        {ExCommerceWeb.CatalogueItemOptionGroupLive.Index, _action} ->
          :catalogue_item_option_groups

        {ExCommerceWeb.CatalogueItemOptionGroupLive.Show, _action} ->
          :catalogue_item_option_groups

        _other ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
