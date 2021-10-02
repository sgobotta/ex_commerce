defmodule ExCommerceWeb.ShopLiveTest do
  @moduledoc false

  use ExCommerceWeb.ConnCase
  use ExCommerceWeb.ResourceCases.MarketplacesCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Accounts.User
  alias ExCommerce.BrandsFixtures
  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Marketplaces.Shop
  alias ExCommerce.ShopsFixtures

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

  defp create_shop(_context) do
    shop = ShopsFixtures.create()
    %{shop: shop}
  end

  defp create_brand(_context) do
    brand = BrandsFixtures.create()
    %{brand: brand}
  end

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_shop,
      :assoc_user_brand,
      :assoc_brand_shop
    ]

    test "[Success] lists all shops for a brand", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      shop: %Shop{name: shop_name}
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.shop_index_path(conn, :index, brand_id))

      assert html =~ "My Shops"
      assert html =~ shop_name
    end

    test "[Failure] does not list all shops when user is not confirmed" do
      %{shop: _shop} = create_shop(%{})
      conn = build_conn()

      to = Routes.user_session_path(conn, :new)

      assert {:error, {:redirect, %{flash: _token, to: ^to}}} =
               live(conn, Routes.shop_index_path(conn, :index))
    end

    test "[Success] saves new shop", %{brand: %Brand{id: brand_id}, conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.shop_index_path(conn, :index, brand_id))

      assert index_live |> element("a", "+") |> render_click() =~
               "New Shop"

      assert_patch(index_live, Routes.shop_index_path(conn, :new, brand_id))

      assert index_live
             |> form("#shop-form", shop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shop-form", shop: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shop_index_path(conn, :index, brand_id))

      assert html =~ "Shop created successfully"
      assert html =~ "some name"
    end

    test "[Success] updates shop in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      shop: %Shop{id: shop_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.shop_index_path(conn, :index, brand_id))

      assert index_live
             |> element("#shop-#{shop_id} a", "Edit")
             |> render_click() =~
               "Edit Shop"

      assert_patch(
        index_live,
        Routes.shop_index_path(conn, :edit, brand_id, shop_id)
      )

      assert index_live
             |> form("#shop-form", shop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#shop-form", shop: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shop_index_path(conn, :index, brand_id))

      assert html =~ "Shop updated successfully"
      assert html =~ "some updated name"
    end

    test "[Success] deletes shop in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      shop: %Shop{id: shop_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.shop_index_path(conn, :index, brand_id))

      assert index_live
             |> element("#shop-#{shop_id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#shop-#{shop_id}")
    end

    test "[Failure] redirects to brands list when no shop id is provided", %{
      conn: conn
    } do
      assert {:error, {:redirect, %{to: to}}} =
               live(conn, Routes.shop_index_path(conn, :index))

      assert to == Routes.brand_index_path(conn, :index)
    end
  end

  describe "Show" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_shop,
      :assoc_user_brand,
      :assoc_brand_shop
    ]

    test "[Success] displays shop", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      shop: %Shop{id: shop_id, name: shop_name}
    } do
      {:ok, _show_live, html} =
        live(conn, Routes.shop_show_path(conn, :show, brand_id, shop_id))

      assert html =~ "Show Shop"
      assert html =~ shop_name
    end

    test "[Failure] does not display a shop when user is not confirmed", %{
      brand: %Brand{id: brand_id}
    } do
      %{shop: %Shop{} = shop} = create_shop(%{})
      conn = build_conn()

      to = Routes.user_session_path(conn, :new)

      assert {:error, {:redirect, %{flash: _token, to: ^to}}} =
               live(conn, Routes.shop_show_path(conn, :show, brand_id, shop))
    end

    test "[Success] updates shop within modal", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      shop: %Shop{id: shop_id}
    } do
      {:ok, show_live, _html} =
        live(conn, Routes.shop_show_path(conn, :show, brand_id, shop_id))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Shop"

      assert_patch(
        show_live,
        Routes.shop_show_path(conn, :edit, brand_id, shop_id)
      )

      assert show_live
             |> form("#shop-form", shop: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#shop-form", shop: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.shop_show_path(conn, :show, brand_id, shop_id)
        )

      assert html =~ "Shop updated successfully"
      assert html =~ "some updated name"
    end

    @tag :wip
    test "[Failure] redirects to brands when invalid brand id is provided", %{
      conn: conn,
      shop: %Shop{id: shop_id}
    } do
      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.shop_show_path(
                   conn,
                   :show,
                   Ecto.UUID.generate(),
                   shop_id
                 )
               )

      assert to == Routes.brand_index_path(conn, :index)

      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.shop_show_path(
                   conn,
                   :edit,
                   Ecto.UUID.generate(),
                   shop_id
                 )
               )

      assert to == Routes.brand_index_path(conn, :index)
    end

    @tag :wip
    test "[Failure] redirects to shops when invalid shop id is provided", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.shop_show_path(
                   conn,
                   :show,
                   brand_id,
                   Ecto.UUID.generate()
                 )
               )

      assert to == Routes.shop_index_path(conn, :index, brand_id)

      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.shop_show_path(
                   conn,
                   :edit,
                   brand_id,
                   Ecto.UUID.generate()
                 )
               )

      assert to == Routes.shop_index_path(conn, :index, brand_id)
    end
  end
end
