defmodule ExCommerceWeb.CatalogueItemLiveTest do
  @moduledoc false

  use ExCommerceWeb.ConnCase
  use ExCommerceWeb.ResourceCases.MarketplacesCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItem

  @create_attrs %{
    code: "some code",
    description: "some description",
    name: "some name"
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    name: "some updated name"
  }
  @invalid_attrs %{code: nil, description: nil, name: nil}

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue_item,
      :assoc_user_brand,
      :assoc_brand_catalogue_item
    ]

    test "[Success] lists all catalogue_items", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item: %CatalogueItem{} = catalogue_item
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.catalogue_item_index_path(conn, :index, brand_id))

      assert html =~ "My Catalogue items"
      assert html =~ catalogue_item.code
    end

    test "[Failure] lists all catalogue_items for a brand - redirects to brands when invalid brand id is provided",
         %{
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_index_path(conn, :index),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] lists all catalogue_items for a brand - redirects to brands when user is not confirmed" do
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_index_path(conn, :index),
        to: Routes.user_session_path(conn, :new)
      )
    end

    test "[Success] saves new catalogue_item", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_item_index_path(conn, :index, brand_id))

      assert index_live |> element("a", "+") |> render_click() =~
               "New Catalogue item"

      assert_patch(
        index_live,
        Routes.catalogue_item_index_path(conn, :new, brand_id)
      )

      assert index_live
             |> form("#catalogue_item-form", catalogue_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue_item-form", catalogue_item: @create_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_item_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue item created successfully"
      assert html =~ "some code"
    end

    test "[Success] updates catalogue_item in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item: %CatalogueItem{id: catalogue_item_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_item_index_path(conn, :index, brand_id))

      assert index_live
             |> element("#catalogue_item-#{catalogue_item_id} a", "Edit")
             |> render_click() =~
               "Edit Catalogue item"

      assert_patch(
        index_live,
        Routes.catalogue_item_index_path(
          conn,
          :edit,
          brand_id,
          catalogue_item_id
        )
      )

      assert index_live
             |> form("#catalogue_item-form", catalogue_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue_item-form", catalogue_item: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_item_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue item updated successfully"
      assert html =~ "some updated code"
    end

    test "[Failure] updates catalogue_item in listing - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_item: %CatalogueItem{id: catalogue_item_id}
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_index_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            catalogue_item_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_index_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates catalogue_item in listing - redirects to catalogue items when invalid catalogue item id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_index_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_item_index_path(conn, :index, brand_id)
      )
    end

    test "[Success] deletes catalogue_item in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item: %CatalogueItem{id: catalogue_item_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_item_index_path(conn, :index, brand_id))

      assert index_live
             |> element("#catalogue_item-#{catalogue_item_id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#catalogue_item-#{catalogue_item_id}")
    end
  end

  describe "Show" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue_item,
      :assoc_user_brand,
      :assoc_brand_catalogue_item
    ]

    test "[Success] displays catalogue_item", %{
      brand: %Brand{id: brand_id},
      catalogue_item: %CatalogueItem{
        id: catalogue_item_id,
        code: catalogue_item_code
      },
      conn: conn
    } do
      {:ok, _show_live, html} =
        live(
          conn,
          Routes.catalogue_item_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_id
          )
        )

      assert html =~ "Show Catalogue item"
      assert html =~ catalogue_item_code
    end

    test "[Failure] displays catalogue item - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_item: %CatalogueItem{id: catalogue_item_id}
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :show,
            Ecto.UUID.generate(),
            catalogue_item_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :show,
            "123",
            catalogue_item_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :show,
            "123",
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_show_path(conn, :show, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] displays catalogue item - redirects to catalogue items when invalid catalogue item id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :show,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_item_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_show_path(conn, :show, brand_id, "123"),
        to: Routes.catalogue_item_index_path(conn, :index, brand_id)
      )
    end

    test "[Failure] displays catalogue item - redirects to log in when user is not confirmed",
         %{
           brand: %Brand{id: brand_id}
         } do
      %{catalogue_item: %CatalogueItem{id: catalogue_item_id}} =
        create_catalogue_item(%{})

      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_id
          ),
        to: Routes.user_session_path(conn, :new)
      )
    end

    test "[Success] updates catalogue_item within modal", %{
      brand: %Brand{id: brand_id},
      catalogue_item: %CatalogueItem{id: catalogue_item_id},
      conn: conn
    } do
      {:ok, show_live, _html} =
        live(
          conn,
          Routes.catalogue_item_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_id
          )
        )

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Catalogue item"

      assert_patch(
        show_live,
        Routes.catalogue_item_show_path(
          conn,
          :edit,
          brand_id,
          catalogue_item_id
        )
      )

      assert show_live
             |> form("#catalogue_item-form", catalogue_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#catalogue_item-form", catalogue_item: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_item_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_id
          )
        )

      assert html =~ "Catalogue item updated successfully"
      assert html =~ "some updated code"
    end

    test "[Failure] updates catalogue item within modal - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_item: %CatalogueItem{id: catalogue_item_id}
         } do
      assert_redirects_with_error(conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            catalogue_item_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :edit,
            "123",
            catalogue_item_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            "123"
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :edit,
            "123",
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_show_path(conn, :edit, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates catalogue item within modal - redirects to catalogue items when invalid catalogue item id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_show_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_item_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_show_path(conn, :edit, brand_id, "123"),
        to: Routes.catalogue_item_index_path(conn, :index, brand_id)
      )
    end
  end
end
