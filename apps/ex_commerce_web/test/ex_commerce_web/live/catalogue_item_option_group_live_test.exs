defmodule ExCommerceWeb.CatalogueItemOptionGroupLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerce.ContextCases.OfferingsCase
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.CatalogueItemOptionGroup

  @create_attrs %{mandatory: true, max_selection: 42, multiple_selection: true}
  @update_attrs %{
    mandatory: false,
    max_selection: 43,
    multiple_selection: false
  }
  @invalid_attrs %{mandatory: nil, max_selection: nil, multiple_selection: nil}

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue_item_option_group,
      :assoc_user_brand,
      :assoc_brand_catalogue_item_option_group
    ]

    @tag :wip
    test "[Success] lists all catalogue_item_option_groups", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      {:ok, _index_live, html} =
        live(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      assert html =~ "Listing Catalogue item option groups"
    end

    @tag :wip
    test "[Failure] lists all catalogue_item_option_groups for a brand - redirects to brands when invalid brand id is provided",
         %{
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_option_group_index_path(conn, :index),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    @tag :wip
    test "[Failure] lists all catalogue_item_option_groups for a brand - redirects to brands when user is not confirmed" do
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_option_group_index_path(conn, :index),
        to: Routes.user_session_path(conn, :new)
      )
    end

    @tag :wip
    test "[Success] saves new catalogue_item_option_group", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      {:ok, index_live, _html} =
        live(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      assert index_live
             |> element("a", "+")
             |> render_click() =~
               "New Catalogue item option group"

      assert_patch(
        index_live,
        Routes.catalogue_item_option_group_index_path(conn, :new, brand_id)
      )

      assert index_live
             |> form("#catalogue_item_option_group-form",
               catalogue_item_option_group: @invalid_attrs
             )

      {:ok, _, html} =
        index_live
        |> form("#catalogue_item_option_group-form",
          catalogue_item_option_group: @create_attrs
        )
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue item option group created successfully"
    end

    @tag :wip
    test "[Success] updates catalogue_item_option_group in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item_option_group: %CatalogueItemOptionGroup{
        id: catalogue_item_option_group_id
      }
    } do
      {:ok, index_live, _html} =
        live(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      assert index_live
             |> element(
               "#catalogue_item_option_group-#{catalogue_item_option_group_id} a",
               "Edit"
             )
             |> render_click() =~
               "Edit Catalogue item option group"

      assert_patch(
        index_live,
        Routes.catalogue_item_option_group_index_path(
          conn,
          :edit,
          brand_id,
          catalogue_item_option_group_id
        )
      )

      assert index_live
             |> form("#catalogue_item_option_group-form",
               catalogue_item_option_group: @invalid_attrs
             )

      {:ok, _, html} =
        index_live
        |> form("#catalogue_item_option_group-form",
          catalogue_item_option_group: @update_attrs
        )
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue item option group updated successfully"
    end

    @tag :wip
    test "[Failure] updates catalogue_item_option_group in listing - redirects to catalogue item option groups when invalid catalogue item option group id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_index_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to:
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
      )
    end

    @tag :wip
    test "deletes catalogue_item_option_group in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item_option_group: %CatalogueItemOptionGroup{
        id: catalogue_item_option_group_id
      }
    } do
      {:ok, index_live, _html} =
        live(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      assert index_live
             |> element(
               "#catalogue_item_option_group-#{catalogue_item_option_group_id} a",
               "Delete"
             )
             |> render_click()

      refute has_element?(
               index_live,
               "#catalogue_item_option_group-#{catalogue_item_option_group_id}"
             )
    end
  end

  describe "Show" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue_item_option_group,
      :assoc_user_brand,
      :assoc_brand_catalogue_item_option_group
    ]

    @tag :wip
    test "[Success] displays catalogue_item_option_group", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item_option_group: %CatalogueItemOptionGroup{
        id: catalogue_item_option_group_id
      }
    } do
      {:ok, _show_live, html} =
        live(
          conn,
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_option_group_id
          )
        )

      assert html =~ "Show Catalogue item option group"
    end

    test "[Failure] displays catalogue item option group - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_item_option_group: %CatalogueItemOptionGroup{
             id: catalogue_item_option_group_id
           }
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            Ecto.UUID.generate(),
            catalogue_item_option_group_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            "123",
            catalogue_item_option_group_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            "123",
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            "123",
            "123"
          ),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] displays catalogue item option group - redirects to catalogue item option groups when invalid catalogue item option group id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            brand_id,
            Ecto.UUID.generate()
          ),
        to:
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            brand_id,
            "123"
          ),
        to:
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
      )
    end

    @tag :wip
    test "[Failure] displays catalogue item option group - redirects to log in when user is not confirmed",
         %{
           brand: %Brand{id: brand_id}
         } do
      %{
        catalogue_item_option_group: %CatalogueItemOptionGroup{
          id: catalogue_item_option_group_id
        }
      } = create_catalogue_item_option_group(%{})

      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_option_group_id
          ),
        to: Routes.user_session_path(conn, :new)
      )
    end

    @tag :wip
    test "[Success] updates catalogue_item_option_group within modal", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item_option_group: %CatalogueItemOptionGroup{
        id: catalogue_item_option_group_id
      }
    } do
      {:ok, show_live, _html} =
        live(
          conn,
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_option_group_id
          )
        )

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Catalogue item option group"

      assert_patch(
        show_live,
        Routes.catalogue_item_option_group_show_path(
          conn,
          :edit,
          brand_id,
          catalogue_item_option_group_id
        )
      )

      assert show_live
             |> form("#catalogue_item_option_group-form",
               catalogue_item_option_group: @invalid_attrs
             )

      #  TODO: fixme
      #  |> render_change() =~ "can&#39;t be blank"

      {:ok, _show_live, html} =
        show_live
        |> form("#catalogue_item_option_group-form",
          catalogue_item_option_group: @update_attrs
        )
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_item_option_group_show_path(
            conn,
            :show,
            brand_id,
            catalogue_item_option_group_id
          )
        )

      assert html =~ "Catalogue item option group updated successfully"
    end

    @tag :wip
    test "[Failure] updates catalogue item option group within modal - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue_item_option_group: %CatalogueItemOptionGroup{
             id: catalogue_item_option_group_id
           }
         } do
      assert_redirects_with_error(conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            catalogue_item_option_group_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :edit,
            "123",
            catalogue_item_option_group_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
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
          Routes.catalogue_item_option_group_show_path(
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
          Routes.catalogue_item_option_group_show_path(
            conn,
            :edit,
            "123",
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :edit,
            "123",
            "123"
          ),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    @tag :wip
    test "[Failure] updates catalogue item option group within modal - redirects to catalogue item option groups when invalid catalogue item option group id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to:
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_item_option_group_show_path(
            conn,
            :edit,
            brand_id,
            "123"
          ),
        to:
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
      )
    end
  end
end
