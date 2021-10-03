defmodule ExCommerceWeb.CatalogueItemLiveTest do
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.Offerings

  @create_attrs %{code: "some code", description: "some description", name: "some name"}
  @update_attrs %{code: "some updated code", description: "some updated description", name: "some updated name"}
  @invalid_attrs %{code: nil, description: nil, name: nil}

  defp fixture(:catalogue_item) do
    {:ok, catalogue_item} = Offerings.create_catalogue_item(@create_attrs)
    catalogue_item
  end

  defp create_catalogue_item(_) do
    catalogue_item = fixture(:catalogue_item)
    %{catalogue_item: catalogue_item}
  end

  describe "Index" do
    setup [:create_catalogue_item]

    test "lists all catalogue_items", %{conn: conn, catalogue_item: catalogue_item} do
      {:ok, _index_live, html} = live(conn, Routes.catalogue_item_index_path(conn, :index))

      assert html =~ "Listing Catalogue items"
      assert html =~ catalogue_item.code
    end

    test "saves new catalogue_item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.catalogue_item_index_path(conn, :index))

      assert index_live |> element("a", "New Catalogue item") |> render_click() =~
               "New Catalogue item"

      assert_patch(index_live, Routes.catalogue_item_index_path(conn, :new))

      assert index_live
             |> form("#catalogue_item-form", catalogue_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue_item-form", catalogue_item: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.catalogue_item_index_path(conn, :index))

      assert html =~ "Catalogue item created successfully"
      assert html =~ "some code"
    end

    test "updates catalogue_item in listing", %{conn: conn, catalogue_item: catalogue_item} do
      {:ok, index_live, _html} = live(conn, Routes.catalogue_item_index_path(conn, :index))

      assert index_live |> element("#catalogue_item-#{catalogue_item.id} a", "Edit") |> render_click() =~
               "Edit Catalogue item"

      assert_patch(index_live, Routes.catalogue_item_index_path(conn, :edit, catalogue_item))

      assert index_live
             |> form("#catalogue_item-form", catalogue_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#catalogue_item-form", catalogue_item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.catalogue_item_index_path(conn, :index))

      assert html =~ "Catalogue item updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes catalogue_item in listing", %{conn: conn, catalogue_item: catalogue_item} do
      {:ok, index_live, _html} = live(conn, Routes.catalogue_item_index_path(conn, :index))

      assert index_live |> element("#catalogue_item-#{catalogue_item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#catalogue_item-#{catalogue_item.id}")
    end
  end

  describe "Show" do
    setup [:create_catalogue_item]

    test "displays catalogue_item", %{conn: conn, catalogue_item: catalogue_item} do
      {:ok, _show_live, html} = live(conn, Routes.catalogue_item_show_path(conn, :show, catalogue_item))

      assert html =~ "Show Catalogue item"
      assert html =~ catalogue_item.code
    end

    test "updates catalogue_item within modal", %{conn: conn, catalogue_item: catalogue_item} do
      {:ok, show_live, _html} = live(conn, Routes.catalogue_item_show_path(conn, :show, catalogue_item))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Catalogue item"

      assert_patch(show_live, Routes.catalogue_item_show_path(conn, :edit, catalogue_item))

      assert show_live
             |> form("#catalogue_item-form", catalogue_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#catalogue_item-form", catalogue_item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.catalogue_item_show_path(conn, :show, catalogue_item))

      assert html =~ "Catalogue item updated successfully"
      assert html =~ "some updated code"
    end
  end
end
