defmodule ExCommerceWeb.PlaceLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Marketplaces.Brand

  describe "Search" do
    test "[Success] search places", %{conn: conn} do
      {:ok, _index_live, html} =
        live(conn, Routes.place_search_path(conn, :search))

      assert html =~ "Search places"
    end
  end

  describe "Index" do
    setup [:create_brand]

    test "[Success] lists all places", %{
      conn: conn,
      brand: %Brand{slug: slug}
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.place_index_path(conn, :index, slug))

      assert html =~ "Places"
    end
  end
end
