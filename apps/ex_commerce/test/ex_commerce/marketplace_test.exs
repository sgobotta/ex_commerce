defmodule ExCommerce.MarketplacesTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.Marketplaces

  describe "shops" do
    alias ExCommerce.Marketplaces.Shop

    @valid_attrs %{name: "some name", slug: "some slug"}
    @update_attrs %{name: "some updated name", slug: "some updated slug"}
    @invalid_attrs %{name: nil, slug: nil}

    def shop_fixture(attrs \\ %{}) do
      {:ok, shop} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Marketplaces.create_shop()

      shop
    end

    test "list_shops/0 returns all shops" do
      shop = shop_fixture()
      assert Marketplaces.list_shops() == [shop]
    end

    test "get_shop!/1 returns the shop with given id" do
      shop = shop_fixture()
      assert Marketplaces.get_shop!(shop.id) == shop
    end

    test "create_shop/1 with valid data creates a shop" do
      assert {:ok, %Shop{} = shop} = Marketplaces.create_shop(@valid_attrs)
      assert shop.name == "some name"
      assert shop.slug == "some slug"
    end

    test "create_shop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.create_shop(@invalid_attrs)
    end

    test "update_shop/2 with valid data updates the shop" do
      shop = shop_fixture()

      assert {:ok, %Shop{} = shop} =
               Marketplaces.update_shop(shop, @update_attrs)

      assert shop.name == "some updated name"
      assert shop.slug == "some updated slug"
    end

    test "update_shop/2 with invalid data returns error changeset" do
      shop = shop_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.update_shop(shop, @invalid_attrs)

      assert shop == Marketplaces.get_shop!(shop.id)
    end

    test "delete_shop/1 deletes the shop" do
      shop = shop_fixture()
      assert {:ok, %Shop{}} = Marketplaces.delete_shop(shop)

      assert_raise Ecto.NoResultsError, fn ->
        Marketplaces.get_shop!(shop.id)
      end
    end

    test "change_shop/1 returns a shop changeset" do
      shop = shop_fixture()
      assert %Ecto.Changeset{} = Marketplaces.change_shop(shop)
    end
  end
end
