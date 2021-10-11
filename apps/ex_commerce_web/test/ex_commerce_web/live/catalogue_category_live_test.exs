defmodule ExCommerceWeb.CatalogueCategoryLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerce.ContextCases.OfferingsCase
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueCategory

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
      :create_catalogue_category,
      :assoc_user_brand,
      :assoc_brand_catalogue_category
    ]

    test "[Success] lists all catalogue_categories", %{
      conn: conn,
      brand: %Brand{id: brand_id},
      catalogue_category: %CatalogueCategory{} = catalogue_category
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.catalogue_category_index_path(conn, :index, brand_id))

      assert html =~ "My Catalogue categories"
      assert html =~ catalogue_category.code
    end

    test "[Failure] lists all catalogue_categories for a brand - redirects to brands when invalid brand id is provided",
         %{
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_category_index_path(conn, :index),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] lists all catalogue_categories for a brand - redirects to brands when user is not confirmed" do
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_category_index_path(conn, :index),
        to: Routes.user_session_path(conn, :new)
      )
    end

    test "[Success] saves new catalogue_category", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_category_index_path(conn, :index, brand_id))

      assert index_live
             |> element("a", "+")
             |> render_click() =~
               "New Catalogue category"

      assert_patch(
        index_live,
        Routes.catalogue_category_index_path(conn, :new, brand_id)
      )

      assert index_live
             |> form("#catalogue_category-form",
               catalogue_category: @invalid_attrs
             )
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue_category-form", catalogue_category: @create_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_category_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue category created successfully"
      assert html =~ "some code"
    end

    test "[Success] updates catalogue_category in listing", %{
      brand: %Brand{id: brand_id},
      catalogue_category: %CatalogueCategory{id: catalogue_category_id},
      conn: conn
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_category_index_path(conn, :index, brand_id))

      assert index_live
             |> element(
               "#catalogue_category-#{catalogue_category_id} a",
               "Edit"
             )
             |> render_click() =~
               "Edit Catalogue category"

      assert_patch(
        index_live,
        Routes.catalogue_category_index_path(
          conn,
          :edit,
          brand_id,
          catalogue_category_id
        )
      )

      assert index_live
             |> form("#catalogue_category-form",
               catalogue_category: @invalid_attrs
             )
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue_category-form", catalogue_category: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_category_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue category updated successfully"
      assert html =~ "some updated code"
    end

    test "[Failure] updates catalogue_category in listing - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_category: %CatalogueCategory{id: catalogue_category_id}
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_index_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            catalogue_category_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_index_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates catalogue_category in listing - redirects to catalogue categories when invalid catalogue category id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_index_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_category_index_path(conn, :index, brand_id)
      )
    end

    test "[Success] deletes catalogue_category in listing", %{
      brand: %Brand{id: brand_id},
      catalogue_category: %CatalogueCategory{id: catalogue_category_id},
      conn: conn
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_category_index_path(conn, :index, brand_id))

      assert index_live
             |> element(
               "#catalogue_category-#{catalogue_category_id} a",
               "Delete"
             )
             |> render_click()

      refute has_element?(
               index_live,
               "#catalogue_category-#{catalogue_category_id}"
             )
    end
  end

  describe "Show" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue_category,
      :assoc_user_brand,
      :assoc_brand_catalogue_category
    ]

    test "[Success] displays catalogue_category", %{
      brand: %Brand{id: brand_id},
      catalogue_category: %CatalogueCategory{
        id: catalogue_category_id,
        code: catalogue_category_code
      },
      conn: conn
    } do
      {:ok, _show_live, html} =
        live(
          conn,
          Routes.catalogue_category_show_path(
            conn,
            :show,
            brand_id,
            catalogue_category_id
          )
        )

      assert html =~ "Show Catalogue category"
      assert html =~ catalogue_category_code
    end

    test "[Failure] displays catalogue category - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_category: %CatalogueCategory{id: catalogue_category_id}
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :show,
            Ecto.UUID.generate(),
            catalogue_category_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :show,
            "123",
            catalogue_category_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :show,
            "123",
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_category_show_path(conn, :show, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] displays catalogue category - redirects to catalogue categories when invalid catalogue category id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :show,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_category_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_category_show_path(conn, :show, brand_id, "123"),
        to: Routes.catalogue_category_index_path(conn, :index, brand_id)
      )
    end

    test "[Failure] displays catalogue category - redirects to log in when user is not confirmed",
         %{
           brand: %Brand{id: brand_id}
         } do
      %{catalogue_category: %CatalogueCategory{id: catalogue_category_id}} =
        create_catalogue_category(%{})

      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :show,
            brand_id,
            catalogue_category_id
          ),
        to: Routes.user_session_path(conn, :new)
      )
    end

    test "[Sucess] updates catalogue_category within modal", %{
      brand: %Brand{id: brand_id},
      catalogue_category: %CatalogueCategory{id: catalogue_category_id},
      conn: conn
    } do
      {:ok, show_live, _html} =
        live(
          conn,
          Routes.catalogue_category_show_path(
            conn,
            :show,
            brand_id,
            catalogue_category_id
          )
        )

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Catalogue category"

      assert_patch(
        show_live,
        Routes.catalogue_category_show_path(
          conn,
          :edit,
          brand_id,
          catalogue_category_id
        )
      )

      assert show_live
             |> form("#catalogue_category-form",
               catalogue_category: @invalid_attrs
             )
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#catalogue_category-form", catalogue_category: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_category_show_path(
            conn,
            :show,
            brand_id,
            catalogue_category_id
          )
        )

      assert html =~ "Catalogue category updated successfully"
      assert html =~ "some updated code"
    end

    test "[Failure] updates catalogue category within modal - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_category: %CatalogueCategory{id: catalogue_category_id}
         } do
      assert_redirects_with_error(conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            catalogue_category_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :edit,
            "123",
            catalogue_category_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
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
          Routes.catalogue_category_show_path(
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
          Routes.catalogue_category_show_path(
            conn,
            :edit,
            "123",
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_category_show_path(conn, :edit, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates catalogue category within modal - redirects to catalogue categories when invalid catalogue category id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_category_show_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_category_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_category_show_path(conn, :edit, brand_id, "123"),
        to: Routes.catalogue_category_index_path(conn, :index, brand_id)
      )
    end
  end
end
