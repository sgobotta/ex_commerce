defmodule ExCommerceWeb.ShopLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerceWeb.ConnCase
  use ExCommerceWeb.UploadsCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Accounts.User
  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Marketplaces.Shop

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

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_shop,
      :assoc_user_brand,
      :assoc_brand_shop
    ]

    defp navigate_new_shop(conn, view, brand_id) do
      assert view |> element("a", "+") |> render_click() =~
               "New Shop"

      assert_patch(view, Routes.shop_index_path(conn, :new, brand_id))

      :ok
    end

    defp change_new_shop(view, attrs) do
      assert view
             |> form("#shop-form", shop: attrs)
             |> render_change() =~ "can&#39;t be blank"

      :ok
    end

    defp submit_new_shop(conn, view, brand_id, create_attrs) do
      {:ok, _, html} =
        view
        |> form("#shop-form", shop: create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.shop_index_path(conn, :index, brand_id))

      assert html =~ "Shop created successfully"
      assert html =~ "some name"

      :ok
    end

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

    test "[Failure] lists all shops for a brand - redirects to brands when invalid brand id is provided",
         %{
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from: Routes.shop_index_path(conn, :index),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] lists all shops for a brand - redirects to brands when user is not confirmed" do
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.shop_index_path(conn, :index),
        to: Routes.user_session_path(conn, :new)
      )
    end

    test "[Success] saves new shop", %{brand: %Brand{id: brand_id}, conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.shop_index_path(conn, :index, brand_id))

      :ok = navigate_new_shop(conn, index_live, brand_id)
      :ok = change_new_shop(index_live, @invalid_attrs)

      :ok =
        upload_photos(
          index_live,
          "#shop-form",
          :avatars,
          valid_uploads_metadata(),
          "cancel_avatar_entry"
        )

      :ok =
        upload_photos(
          index_live,
          "#shop-form",
          :banners,
          valid_uploads_metadata(),
          "cancel_banner_entry"
        )

      :ok = submit_new_shop(conn, index_live, brand_id, @create_attrs)
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

    test "[Failure] updates shop in listing - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           shop: %Shop{id: shop_id}
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.shop_index_path(conn, :edit, Ecto.UUID.generate(), shop_id),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.shop_index_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates shop in listing - redirects to shops when invalid shop id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.shop_index_path(conn, :edit, brand_id, Ecto.UUID.generate()),
        to: Routes.shop_index_path(conn, :index, brand_id)
      )
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

    test "[Failure] displays shop - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           shop: %Shop{id: shop_id}
         } do
      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :show, Ecto.UUID.generate(), shop_id),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :show, "123", shop_id),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :show, "123", Ecto.UUID.generate()),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :show, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] displays shop - redirects to shops when invalid shop id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.shop_show_path(conn, :show, brand_id, Ecto.UUID.generate()),
        to: Routes.shop_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :show, brand_id, "123"),
        to: Routes.shop_index_path(conn, :index, brand_id)
      )
    end

    test "[Failure] displays shop - redirects to log in when user is not confirmed",
         %{
           brand: %Brand{id: brand_id}
         } do
      %{shop: %Shop{id: shop_id}} = create_shop(%{})
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :show, brand_id, shop_id),
        to: Routes.user_session_path(conn, :new)
      )
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

    test "[Failure] updates shop within modal - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           shop: %Shop{id: shop_id}
         } do
      assert_redirects_with_error(conn,
        from: Routes.shop_show_path(conn, :edit, Ecto.UUID.generate(), shop_id),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :edit, "123", shop_id),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.shop_show_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :edit, Ecto.UUID.generate(), "123"),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :edit, "123", Ecto.UUID.generate()),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :edit, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates shop within modal - redirects to shops when invalid shop id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.shop_show_path(conn, :edit, brand_id, Ecto.UUID.generate()),
        to: Routes.shop_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.shop_show_path(conn, :edit, brand_id, "123"),
        to: Routes.shop_index_path(conn, :index, brand_id)
      )
    end
  end

  describe "PublicIndex" do
    setup [
      :create_brand,
      :create_shop,
      :assoc_brand_shop
    ]

    @tag :wip
    test "[Success] lists all shops", %{
      conn: conn,
      shop: %Shop{}
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.shop_public_index_path(conn, :index))

      assert html =~ "Choose a shop!"
    end
  end

  describe "PublicShow" do
    setup [
      :create_brand,
      :create_shop,
      :assoc_brand_shop
    ]

    @tag :skip
    test "[Success] displays shop", %{
      conn: conn,
      brand: %Brand{slug: brand_slug, name: _brand_name},
      shop: %Shop{slug: shop_slug}
    } do
      {:ok, _show_live, html} =
        live(conn, Routes.shop_public_show_path(conn, :show, shop_slug))

      assert html =~ "Shop!"
    end

    @tag :skip
    test "[Failure] displays shop - redirects on invalid shop id", %{
      conn: conn
    } do
      assert_redirects_with_error(
        conn,
        from: Routes.shop_public_show_path(conn, :show, "some-invalid-slug"),
        to: Routes.shop_public_index_path(conn, :index)
      )
    end
  end
end
