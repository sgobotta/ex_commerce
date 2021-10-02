defmodule ExCommerceWeb.BrandLiveTest do
  @moduledoc false

  use ExCommerceWeb.ConnCase
  use ExCommerceWeb.ResourceCases.MarketplacesCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :assoc_user_brand
    ]

    test "[Success] lists all brands", %{
      conn: conn,
      brand: %Brand{name: brand_name}
    } do
      {:ok, _index_live, html} =
        live(conn, Routes.brand_index_path(conn, :index))

      assert html =~ "My Brands"
      assert html =~ brand_name
    end

    test "[Success] saves new brand", %{conn: conn} do
      {:ok, index_live, _html} =
        live(conn, Routes.brand_index_path(conn, :index))

      assert index_live |> element("a", "+") |> render_click() =~
               "New Brand"

      assert_patch(index_live, Routes.brand_index_path(conn, :new))

      assert index_live
             |> form("#brand-form", brand: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#brand-form", brand: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.brand_index_path(conn, :index))

      assert html =~ "Brand created successfully"
      assert html =~ "some name"
    end

    test "[Success] updates brand in listing", %{
      conn: conn,
      brand: %Brand{id: brand_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.brand_index_path(conn, :index))

      assert index_live
             |> element("#brand-#{brand_id} a", "Edit")
             |> render_click() =~
               "Edit Brand"

      assert_patch(index_live, Routes.brand_index_path(conn, :edit, brand_id))

      assert index_live
             |> form("#brand-form", brand: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#brand-form", brand: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.brand_index_path(conn, :index))

      assert html =~ "Brand updated successfully"
      assert html =~ "some updated name"
    end

    test "[Failure] updates brand in listing - redirects to brands", %{
      conn: conn
    } do
      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.brand_index_path(conn, :edit, Ecto.UUID.generate())
               )

      assert to == Routes.brand_index_path(conn, :index)
    end

    @tag :skip
    test "[Success] deletes brand in listing", %{
      conn: conn,
      brand: %Brand{id: brand_id}
    } do
      {:ok, index_live, _html} =
        live(conn, Routes.brand_index_path(conn, :index))

      assert index_live
             |> element("#brand-#{brand_id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#brand-#{brand_id}")
    end
  end

  describe "Show" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :assoc_user_brand
    ]

    test "[Success] displays brand", %{
      conn: conn,
      brand: %Brand{id: brand_id, name: brand_name}
    } do
      {:ok, _show_live, html} =
        live(conn, Routes.brand_show_path(conn, :show, brand_id))

      assert html =~ brand_name
    end

    test "[Failure] displays brand - redirects on invalid brand id", %{
      conn: conn
    } do
      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.brand_show_path(conn, :show, Ecto.UUID.generate())
               )

      assert to == Routes.brand_index_path(conn, :index)

      assert {:error, {:redirect, %{to: to}}} =
               live(conn, Routes.brand_show_path(conn, :show, "123"))

      assert to == Routes.brand_index_path(conn, :index)
    end

    test "[Success] updates brand within modal", %{
      conn: conn,
      brand: %Brand{id: brand_id}
    } do
      {:ok, show_live, _html} =
        live(conn, Routes.brand_show_path(conn, :show, brand_id))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Brand"

      assert_patch(show_live, Routes.brand_show_path(conn, :edit, brand_id))

      assert show_live
             |> form("#brand-form", brand: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#brand-form", brand: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.brand_show_path(conn, :show, brand_id))

      assert html =~ "Brand updated successfully"
      assert html =~ "some updated name"
    end

    test "[Failure] updates brand within modal - redirects on invalid brand id",
         %{conn: conn} do
      assert {:error, {:redirect, %{to: to}}} =
               live(
                 conn,
                 Routes.brand_show_path(conn, :edit, Ecto.UUID.generate())
               )

      assert to == Routes.brand_index_path(conn, :index)

      live(conn, Routes.brand_show_path(conn, :edit, "123"))

      assert to == Routes.brand_index_path(conn, :index)
    end
  end
end
