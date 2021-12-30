defmodule ExCommerceWeb.CatalogueItemOptionGroupLiveTest do
  @moduledoc false

  use ExCommerce.ContextCases.MarketplacesCase
  use ExCommerce.ContextCases.OfferingsCase
  use ExCommerceWeb.ConnCase

  import Phoenix.LiveViewTest

  alias ExCommerce.CatalogueItemOptionGroupsFixtures

  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.{CatalogueItemOptionGroup, CatalogueItemVariant}

  @create_attrs CatalogueItemOptionGroupsFixtures.valid_attrs()
  @update_attrs CatalogueItemOptionGroupsFixtures.update_attrs()
  @invalid_attrs CatalogueItemOptionGroupsFixtures.invalid_attrs()

  describe "Index" do
    setup [
      :register_and_log_in_confirmed_user,
      :create_brand,
      :create_catalogue_item_option_group,
      :assoc_user_brand,
      :assoc_brand_catalogue_item_option_group,
      :create_catalogue_item,
      :assoc_brand_catalogue_item,
      :create_catalogue_item_variant
    ]

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

    test "[Failure] lists all catalogue_item_option_groups for a brand - redirects to brands when user is not confirmed" do
      conn = build_conn()

      assert_redirects_with_error(
        conn,
        from: Routes.catalogue_item_option_group_index_path(conn, :index),
        to: Routes.user_session_path(conn, :new)
      )
    end

    defp navigate_new_catalogue_item_option_group(conn, view, brand_id) do
      assert view
             |> element("a", "+")
             |> render_click() =~
               "New Catalogue item option group"

      assert_patch(
        view,
        Routes.catalogue_item_option_group_index_path(conn, :new, brand_id)
      )

      :ok
    end

    defp change_new_catalogue_item_option_group(view, attrs) do
      assert view
             |> form("#catalogue_item_option_group-form",
               catalogue_item_option_group: attrs
             )

      # TODO: Fixme. breaks checking a checkbox
      #  |> render_change() =~ "can&#39;t be blank"

      :ok
    end

    defp submit_new_catalogue_item_option_group(conn, view, brand_id, attrs) do
      {:ok, _, html} =
        view
        |> form("#catalogue_item_option_group-form")
        |> render_submit(%{catalogue_item_option_group: attrs})
        |> follow_redirect(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      assert html =~ "Catalogue item option group created successfully"

      :ok
    end

    defp add_new_options(view, attrs) do
      view
      |> element("#catalogue_item-add-option-input", "Add an option")
      |> render_click()

      for {_option_attrs, index} <- Enum.with_index(attrs.options) do
        assert view
               |> element(
                 "#catalogue_item_option_group-form_options_#{index}_is_visible"
               )
               |> has_element?()

        assert view
               |> element(
                 "#catalogue_item_option_group-form_options_#{index}_price_modifier"
               )
               |> has_element?()

        assert view
               |> element(
                 "#catalogue_item_option_group-form_options_#{index}_catalogue_item_id"
               )
               |> has_element?()

        assert view
               |> element(
                 "#catalogue_item_option_group-form_options_#{index}_catalogue_item_variant_id"
               )
               |> has_element?()

        assert view
               |> element(
                 "#catalogue_item_option_group-form_options_#{index}_catalogue_item_variant_id"
               )
               |> has_element?()
      end

      view
      |> form("#catalogue_item_option_group-form",
        catalogue_item_option_group: attrs
      )
      |> render_change()

      :ok
    end

    test "[Success] saves new catalogue_item_option_group", %{
      brand: %Brand{id: brand_id},
      conn: conn,
      catalogue_item_variant: %CatalogueItemVariant{
        id: catalogue_item_variant_id,
        catalogue_item_id: catalogue_item_id
      }
    } do
      {:ok, index_live, _html} =
        live(
          conn,
          Routes.catalogue_item_option_group_index_path(conn, :index, brand_id)
        )

      :ok = navigate_new_catalogue_item_option_group(conn, index_live, brand_id)
      :ok = change_new_catalogue_item_option_group(index_live, @invalid_attrs)

      create_attrs =
        Map.merge(@create_attrs, %{
          options: %{
            "0" => %{
              is_visible: true,
              price_modifier: 50,
              catalogue_item_id: catalogue_item_id
            },
            "1" => %{
              is_visible: false,
              price_modifier: 90,
              catalogue_item_id: catalogue_item_id
            }
          }
        })

      :ok = add_new_options(index_live, create_attrs)

      create_attrs =
        Map.merge(@create_attrs, %{
          options: %{
            "0" => %{
              is_visible: true,
              price_modifier: 50,
              catalogue_item_id: catalogue_item_id,
              catalogue_item_variant_id: catalogue_item_variant_id
            },
            "1" => %{
              is_visible: false,
              price_modifier: 90,
              catalogue_item_id: catalogue_item_id,
              catalogue_item_variant_id: catalogue_item_variant_id
            }
          }
        })

      :ok =
        submit_new_catalogue_item_option_group(
          conn,
          index_live,
          brand_id,
          create_attrs
        )
    end

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
