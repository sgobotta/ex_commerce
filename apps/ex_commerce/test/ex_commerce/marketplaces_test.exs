defmodule ExCommerce.MarketplacesTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.Marketplaces

  describe "shops" do
    alias ExCommerce.Marketplaces.Shop

    @valid_attrs %{
      name: "some name",
      slug: "some-slug",
      description: "some description",
      telephone: "some telephone",
      banner_message: "some banner_message",
      address: "some address"
    }
    @update_attrs %{
      name: "some updated name",
      slug: "some-updated-slug",
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
      assert shop.slug == "some-slug"
      assert shop.description == "some description"
      assert shop.telephone == "some telephone"
      assert shop.banner_message == "some banner_message"
      assert shop.address == "some address"
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
      assert shop.slug == "some-updated-slug"
      assert shop.description == "some updated description"
      assert shop.telephone == "some updated telephone"
      assert shop.banner_message == "some updated banner_message"
      assert shop.address == "some updated address"
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

  describe "brands" do
    alias ExCommerce.Marketplaces.Brand

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Marketplaces.create_brand()

      brand
    end

    test "list_brands/0 returns all brands" do
      brand = brand_fixture()
      assert Marketplaces.list_brands() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      brand = brand_fixture()
      assert Marketplaces.get_brand!(brand.id) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Marketplaces.create_brand(@valid_attrs)
      assert brand.name == "some name"
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.create_brand(@invalid_attrs)
    end

    test "update_brand/2 with valid data updates the brand" do
      brand = brand_fixture()

      assert {:ok, %Brand{} = brand} =
               Marketplaces.update_brand(brand, @update_attrs)

      assert brand.name == "some updated name"
    end

    test "update_brand/2 with invalid data returns error changeset" do
      brand = brand_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.update_brand(brand, @invalid_attrs)

      assert brand == Marketplaces.get_brand!(brand.id)
    end

    test "delete_brand/1 deletes the brand" do
      brand = brand_fixture()
      assert {:ok, %Brand{}} = Marketplaces.delete_brand(brand)

      assert_raise Ecto.NoResultsError, fn ->
        Marketplaces.get_brand!(brand.id)
      end
    end

    test "change_brand/1 returns a brand changeset" do
      brand = brand_fixture()
      assert %Ecto.Changeset{} = Marketplaces.change_brand(brand)
    end
  end
end
