defmodule ExCommerceWeb.CatalogueLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerce.ContextCases.OfferingsCase
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.CataloguesFixtures

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.Catalogue

  @create_attrs CataloguesFixtures.valid_attrs()
  @update_attrs CataloguesFixtures.update_attrs()
  @invalid_attrs CataloguesFixtures.invalid_attrs()

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue,
      :assoc_user_brand,
      :assoc_brand_catalogue
    ]

    test "[Success] lists all catalogues", %{
      conn: conn,
      brand: %Brand{id: brand_id},
      catalogue: %Catalogue{name: catalogue_name}
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.catalogue_index_path(conn, :index, brand_id))

      assert html =~ "My Catalogues"
      assert html =~ catalogue_name
    end

    test "[Failure] lists all catalogues for a brand - redirects to brands when invalid brand id is provided",
         %{
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_index_path(conn, :index),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] lists all catalogues for a brand - redirects to brands when user is not confirmed" do
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_index_path(conn, :index),
        to: Routes.user_session_path(conn, :new)
      )
    end

    test "[Success] saves new catalogue", %{
      brand: %Brand{id: brand_id},
      conn: conn
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_index_path(conn, :index, brand_id))

      assert index_live |> element("a", "+") |> render_click() =~
               "New Catalogue"

      assert_patch(
        index_live,
        Routes.catalogue_index_path(conn, :new, brand_id)
      )

      assert index_live
             |> form("#catalogue-form", catalogue: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue-form", catalogue: @create_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue created successfully"
      assert html =~ "some name"
    end

    test "[Success] updates catalogue in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue: %Catalogue{id: catalogue_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_index_path(conn, :index, brand_id))

      assert index_live
             |> element("#catalogue-#{catalogue_id} a", "Edit")
             |> render_click() =~
               "Edit Catalogue"

      assert_patch(
        index_live,
        Routes.catalogue_index_path(conn, :edit, brand_id, catalogue_id)
      )

      assert index_live
             |> form("#catalogue-form", catalogue: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue-form", catalogue: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue updated successfully"
      assert html =~ "some updated name"
    end

    test "[Failure] updates catalogue in listing - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue: %Catalogue{id: catalogue_id}
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_index_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            catalogue_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_index_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            Ecto.UUID.generate()
          ),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates catalogue in listing - redirects to catalogues when invalid catalogue id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_index_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_index_path(conn, :index, brand_id)
      )
    end

    test "[Success] deletes catalogue in listing", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue: %Catalogue{id: catalogue_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.catalogue_index_path(conn, :index, brand_id))

      assert index_live
             |> element("#catalogue-#{catalogue_id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#catalogue-#{catalogue_id}")
    end
  end

  describe "Show" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue,
      :assoc_user_brand,
      :assoc_brand_catalogue
    ]

    test "[Success] displays catalogue", %{
      conn: conn,
      brand: %Brand{id: brand_id},
      catalogue: %Catalogue{id: catalogue_id, name: catalogue_name}
    } do
      {:ok, _show_live, html} =
        live(
          conn,
          Routes.catalogue_show_path(conn, :show, brand_id, catalogue_id)
        )

      assert html =~ "Show Catalogue"
      assert html =~ catalogue_name
    end

    test "[Failure] displays catalogue - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue: %Catalogue{id: catalogue_id}
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_show_path(
            conn,
            :show,
            Ecto.UUID.generate(),
            catalogue_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_show_path(conn, :show, "123", catalogue_id),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_show_path(conn, :show, "123", Ecto.UUID.generate()),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_show_path(conn, :show, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] displays catalogue - redirects to catalogues when invalid catalogue id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_show_path(
            conn,
            :show,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_show_path(conn, :show, brand_id, "123"),
        to: Routes.catalogue_index_path(conn, :index, brand_id)
      )
    end

    test "[Failure] displays catalogue - redirects to log in when user is not confirmed",
         %{
           brand: %Brand{id: brand_id}
         } do
      %{catalogue: %Catalogue{id: catalogue_id}} = create_catalogue(%{})
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_show_path(conn, :show, brand_id, catalogue_id),
        to: Routes.user_session_path(conn, :new)
      )
    end

    test "[Success] updates catalogue within modal", %{
      conn: conn,
      brand: %Brand{id: brand_id},
      catalogue: %Catalogue{id: catalogue_id}
    } do
      {:ok, show_live, _html} =
        live(
          conn,
          Routes.catalogue_show_path(conn, :show, brand_id, catalogue_id)
        )

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Catalogue"

      assert_patch(
        show_live,
        Routes.catalogue_show_path(conn, :edit, brand_id, catalogue_id)
      )

      assert show_live
             |> form("#catalogue-form", catalogue: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#catalogue-form", catalogue: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.catalogue_show_path(conn, :show, brand_id, catalogue_id)
        )

      assert html =~ "Catalogue updated successfully"
      assert html =~ "some updated name"
    end

    test "[Failure] updates catalogue within modal - redirects to brands when invalid brand id is provided",
         %{
           conn: conn,
           catalogue: %Catalogue{id: catalogue_id}
         } do
      assert_redirects_with_error(conn,
        from:
          Routes.catalogue_show_path(
            conn,
            :edit,
            Ecto.UUID.generate(),
            catalogue_id
          ),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_show_path(conn, :edit, "123", catalogue_id),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_show_path(
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
          Routes.catalogue_show_path(conn, :edit, Ecto.UUID.generate(), "123"),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_show_path(conn, :edit, "123", Ecto.UUID.generate()),
        to: Routes.brand_index_path(conn, :index)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_show_path(conn, :edit, "123", "123"),
        to: Routes.brand_index_path(conn, :index)
      )
    end

    test "[Failure] updates catalogue within modal - redirects to catalogues when invalid catalogue id is provided",
         %{
           brand: %Brand{id: brand_id},
           conn: conn
         } do
      assert_redirects_with_error(
        conn,
        from:
          Routes.catalogue_show_path(
            conn,
            :edit,
            brand_id,
            Ecto.UUID.generate()
          ),
        to: Routes.catalogue_index_path(conn, :index, brand_id)
      )

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_show_path(conn, :edit, brand_id, "123"),
        to: Routes.catalogue_index_path(conn, :index, brand_id)
      )
    end
  end
end
