defmodule ExCommerceWeb.ShopLiveTest do
  @moduledoc false

  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Marketplaces

  @create_attrs %{
    name: "some name",
    slug: "some-slug",
    description: "some description",
    telephone: "some telephone",
    banner_message: "some banner_message",
    address: "some address"
  }
  @update_attrs %{
    name: "some updated name",
    slug: "some-updated slug",
    description: "some updated description",
    telephone: "some updated telephone",
    banner_message: "some updated banner_message",
    address: "some updated address"
  }
  @invalid_attrs %{
    name: nil,
    slug: nil,
    description: nil,
    telephone: nil,
    banner_message: nil,
    address: nil
  }

  defp fixture(:shop) do
    {:ok, shop} = Marketplaces.create_shop(@create_attrs)
    shop
  end

  defp create_shop(_context) do
    shop = fixture(:shop)
    %{shop: shop}
  end

  describe "Index" do
    setup [:register_and_log_in_confirmed_user, :create_shop]

    test "lists all shops", %{conn: conn, shop: shop} do
      {:ok, _index_live, html} =
        live(conn, Routes.shop_index_path(conn, :index))

      assert html =~ "Listing Shops"
      assert html =~ shop.name
    end

    test "does not list all shops when user is not confirmed" do
      %{shop: _shop} = create_shop(%{})
      conn = build_conn()

      to = Routes.user_session_path(conn, :new)

      assert {:error, {:redirect, %{flash: _token, to: ^to}}} =
               live(conn, Routes.shop_index_path(conn, :index))
    end

    test "saves new shop", %{conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.shop_index_path(conn, :index))

      assert index_live |> element("a", "New Shop") |> render_click() =~
               "New Shop"

      assert_patch(index_live, Routes.shop_index_path(conn, :new))

      assert index_live
             |> form("#shop-form", shop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shop-form", shop: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shop_index_path(conn, :index))

      assert html =~ "Shop created successfully"
      assert html =~ "some name"
    end

    test "updates shop in listing", %{conn: conn, shop: shop} do
      {:ok, index_live, _html} =
        live(conn, Routes.shop_index_path(conn, :index))

      assert index_live
             |> element("#shop-#{shop.id} a", "Edit")
             |> render_click() =~
               "Edit Shop"

      assert_patch(index_live, Routes.shop_index_path(conn, :edit, shop))

      assert index_live
             |> form("#shop-form", shop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shop-form", shop: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shop_index_path(conn, :index))

      assert html =~ "Shop updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes shop in listing", %{conn: conn, shop: shop} do
      {:ok, index_live, _html} =
        live(conn, Routes.shop_index_path(conn, :index))

      assert index_live
             |> element("#shop-#{shop.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#shop-#{shop.id}")
    end
  end

  describe "Show" do
    setup [:register_and_log_in_confirmed_user, :create_shop]

    test "displays shop", %{conn: conn, shop: shop} do
      {:ok, _show_live, html} =
        live(conn, Routes.shop_show_path(conn, :show, shop))

      assert html =~ "Show Shop"
      assert html =~ shop.name
    end

    test "does not display a shop when user is not confirmed" do
      %{shop: shop} = create_shop(%{})
      conn = build_conn()

      to = Routes.user_session_path(conn, :new)

      assert {:error, {:redirect, %{flash: _token, to: ^to}}} =
               live(conn, Routes.shop_show_path(conn, :show, shop))
    end

    test "updates shop within modal", %{conn: conn, shop: shop} do
      {:ok, show_live, _html} =
        live(conn, Routes.shop_show_path(conn, :show, shop))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Shop"

      assert_patch(show_live, Routes.shop_show_path(conn, :edit, shop))

      assert show_live
             |> form("#shop-form", shop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#shop-form", shop: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shop_show_path(conn, :show, shop))

      assert html =~ "Shop updated successfully"
      assert html =~ "some updated name"
    end
  end
end
