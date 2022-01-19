defmodule ExCommerceWeb.PlaceLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Marketplaces.Brand

  describe "Search" do
    @tag :wip
    test "[Success] search places", %{conn: conn} do
      {:ok, _index_live, html} =
        live(conn, Routes.place_search_path(conn, :search))

      assert html =~ "Search places"
    end
  end

  describe "Index" do
    setup [:create_brand]

    @tag :wip
    test "[Success] lists all places", %{
      conn: conn,
      brand: %Brand{name: brand_name, slug: slug}
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.place_index_path(conn, :index, slug))

      assert html =~ "Places"
    end
  end

  describe "Show" do
    setup [
      :create_brand,
      :create_shop,
      :assoc_brand_shop
    ]

    @tag :wip
    test "[Success] displays brand", %{
      conn: conn,
      brand: %Brand{slug: brand_slug, name: brand_name},
      shop: %Shop{slug: shop_slug}
    } do
      {:ok, _show_live, html} =
        live(conn, Routes.place_show_path(conn, :show, brand_slug, shop_slug))

      assert html =~ "Place"
    end

    @tag :wip
    test "[Failure] displays brand - redirects on invalid brand slug", %{
      conn: conn
    } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.place_show_path(
            conn,
            :show,
            "some-invalid-brand-slug",
            "some-invalid-shop-slug"
          ),
        to: Routes.place_search_path(conn, :search)
      )
    end
  end
end
