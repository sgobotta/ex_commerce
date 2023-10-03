defmodule ExCommerceWeb.QrControllerTest do
  @moduledoc false
  use ExCommerceWeb.ConnCase, async: true
  use ExCommerce.ContextCases.CheckoutCase

  describe "GET /qr-cores" do
    setup [
      :create_catalogue,
      :create_shop,
      :relate_shop_catalogue,
      :get_updated_entities
    ]

    test "Redirects to the checkout shop view", %{
      conn: conn,
      shop: %Shop{
        brand: %Brand{id: brand_id, slug: brand_slug},
        id: shop_id,
        slug: shop_slug
      }
    } do
      params = %{to: "checkout_shop", brand_id: brand_id, shop_id: shop_id}
      args = Jason.encode!(params) |> Base.encode64()
      conn = do_get(conn, args: args)

      assert redirected_to(conn) ==
               Routes.checkout_shop_path(conn, :index, brand_slug, shop_slug)
    end

    test "Redirects to the checkout catalogue view", %{
      conn: conn,
      shop: %Shop{
        brand: %Brand{id: brand_id, slug: brand_slug},
        id: shop_id,
        slug: shop_slug
      },
      catalogue: %Catalogue{id: catalogue_id}
    } do
      params = %{
        to: "checkout_catalogue",
        brand_id: brand_id,
        shop_id: shop_id,
        catalogue_id: catalogue_id
      }

      args = Jason.encode!(params) |> Base.encode64()
      conn = do_get(conn, args: args)

      assert redirected_to(conn) ==
               Routes.checkout_catalogue_path(
                 conn,
                 :index,
                 brand_slug,
                 shop_slug,
                 catalogue_id
               )
    end

    test "Redirects to root when the entities don't exist", %{
      conn: conn,
      shop: %Shop{},
      catalogue: %Catalogue{}
    } do
      path_params = [
        to: "checkout_catalogue",
        brand_id: Ecto.UUID.generate(),
        shop_id: Ecto.UUID.generate(),
        catalogue_id: Ecto.UUID.generate()
      ]

      conn = do_get(conn, path_params)

      assert redirected_to(conn) == "/"
    end

    test "Redirects to root when the entities ids are invalid", %{
      conn: conn,
      shop: %Shop{},
      catalogue: %Catalogue{}
    } do
      path_params = [
        to: "checkout_catalogue",
        brand_id: "brand_id",
        shop_id: "shop_id",
        catalogue_id: "catalogue_id"
      ]

      conn = do_get(conn, path_params)

      assert redirected_to(conn) == "/"
    end

    test "Redirects to root when the path params are invalid", %{
      conn: conn,
      shop: %Shop{},
      catalogue: %Catalogue{}
    } do
      # The `to` param is missing
      path_params = [
        to: "",
        brand_id: "brand_id",
        shop_id: "shop_id",
        catalogue_id: "catalogue_id"
      ]

      conn = do_get(conn, path_params)

      assert redirected_to(conn) == "/"

      # The `to` param is invalid
      path_params = [
        to: "invalid_route",
        brand_id: "brand_id",
        shop_id: "shop_id",
        catalogue_id: "catalogue_id"
      ]

      conn = do_get(conn, path_params)

      assert redirected_to(conn) == "/"

      # The `to` param does not exist
      path_params = [
        brand_id: "brand_id",
        shop_id: "shop_id",
        catalogue_id: "catalogue_id"
      ]

      conn = do_get(conn, path_params)

      assert redirected_to(conn) == "/"

      # The `brand_id` is missing
      path_params = [
        to: "checkout_catalogue",
        shop_id: "shop_id",
        catalogue_id: "catalogue_id"
      ]

      conn = do_get(conn, path_params)

      assert redirected_to(conn) == "/"
    end

    defp get_updated_entities(%{
           catalogue: %Catalogue{id: catalogue_id},
           shop: %Shop{id: shop_id}
         }) do
      %Shop{} =
        shop =
        ExCommerce.Marketplaces.get_shop!(shop_id)
        |> ExCommerce.Repo.preload(:brand)

      %Catalogue{} =
        catalogue = ExCommerce.Offerings.get_catalogue!(catalogue_id)

      %{catalogue: catalogue, shop: shop}
    end
  end

  defp do_get(conn, path_parms),
    do: get(conn, Routes.qr_path(conn, :detour, path_parms))
end
