defmodule ExCommerceWeb.HomeLiveTest do
  @moduledoc false

  use ExCommerceWeb.ConnCase
  use ExCommerceWeb.ResourceCases.MarketplacesCase

  import Phoenix.LiveViewTest

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :assoc_user_brand
    ]

    test "[Success] visits the homepage", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.home_index_path(conn, :index, brand_id))

      assert html =~ "Home"
    end

    test "[Failure] visits the homepage - redirects to brands", %{conn: conn} do
      assert {:error, {:redirect, %{to: to}}} =
               live(conn, Routes.home_index_path(conn, :index))

      assert to == Routes.brand_index_path(conn, :index)

      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.home_index_path(conn, :index, Ecto.UUID.generate())
               )

      assert to == Routes.brand_index_path(conn, :index)

      assert {:error, {:redirect, %{to: to}}} =
               live(conn, Routes.home_index_path(conn, :index, "123"))

      assert to == Routes.brand_index_path(conn, :index)
    end
  end
end
