defmodule ExCommerceWeb.HomeLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :assoc_user_brand
    ]

    test "[Success] visits the overview page", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.overview_index_path(conn, :index, brand_id))

      assert html =~ "Home"
    end

    test "[Failure] visits the overview page - redirects to brands", %{
      conn: conn
    } do
      assert_redirects_with_error(
        conn,
        from: Routes.overview_index_path(conn, :index),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.overview_index_path(conn, :index, Ecto.UUID.generate()),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.overview_index_path(conn, :index, "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end
  end
end
