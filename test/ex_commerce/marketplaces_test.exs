defmodule ExCommerce.MarketplacesTest do
  @moduledoc false

  use ExCommerce.DataCase

  alias ExCommerce.Marketplaces

  describe "shops" do
    alias ExCommerce.BrandsFixtures
    alias ExCommerce.Marketplaces.Brand
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
      address: nil,
      brand_id: nil
    }

    setup do
      %{brand: BrandsFixtures.create()}
    end

    def shop_fixture(attrs \\ %{}) do
      {:ok, %Shop{} = shop} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Marketplaces.create_shop()

      shop
    end

    test "list_shops/0 returns all shops", %{brand: %Brand{id: brand_id}} do
      %Shop{} = shop = shop_fixture(%{brand_id: brand_id})
      assert Marketplaces.list_shops() == [shop]
    end

    test "get_shop!/1 returns the shop with given id", %{
      brand: %Brand{id: brand_id}
    } do
      %Shop{id: shop_id} = shop = shop_fixture(%{brand_id: brand_id})
      assert Marketplaces.get_shop!(shop_id) == shop
    end

    test "get_shop_by_brand_slug/1 returns the shop with given brand and shop slug",
         %{
           brand: %Brand{id: brand_id, slug: brand_slug}
         } do
      %Shop{slug: shop_slug} = shop = shop_fixture(%{brand_id: brand_id})
      assert Marketplaces.get_shop_by_brand_slug(brand_slug, shop_slug) == shop
    end

    test "create_shop/1 with valid data creates a shop", %{
      brand: %Brand{id: brand_id}
    } do
      valid_attrs = Map.merge(@valid_attrs, %{brand_id: brand_id})

      assert {:ok, %Shop{} = shop} = Marketplaces.create_shop(valid_attrs)
      assert shop.name == @valid_attrs.name
      assert shop.slug == @valid_attrs.slug
      assert shop.description == @valid_attrs.description
      assert shop.telephone == @valid_attrs.telephone
      assert shop.banner_message == @valid_attrs.banner_message
      assert shop.address == @valid_attrs.address
    end

    test "create_shop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.create_shop(@invalid_attrs)
    end

    test "update_shop/2 with valid data updates the shop", %{
      brand: %Brand{id: brand_id}
    } do
      %Shop{} = shop = shop_fixture(%{brand_id: brand_id})

      assert {:ok, %Shop{} = shop} =
               Marketplaces.update_shop(shop, @update_attrs)

      assert shop.name == @update_attrs.name
      assert shop.slug == @update_attrs.slug
      assert shop.description == @update_attrs.description
      assert shop.telephone == @update_attrs.telephone
      assert shop.banner_message == @update_attrs.banner_message
      assert shop.address == @update_attrs.address
    end

    test "update_shop/2 with invalid data returns error changeset", %{
      brand: %Brand{id: brand_id}
    } do
      %Shop{id: shop_id} = shop = shop_fixture(%{brand_id: brand_id})

      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.update_shop(shop, @invalid_attrs)

      assert shop == Marketplaces.get_shop!(shop_id)
    end

    test "delete_shop/1 deletes the shop", %{brand: %Brand{id: brand_id}} do
      %Shop{id: shop_id} = shop = shop_fixture(%{brand_id: brand_id})
      assert {:ok, %Shop{}} = Marketplaces.delete_shop(shop)

      assert_raise Ecto.NoResultsError, fn ->
        Marketplaces.get_shop!(shop_id)
      end
    end

    test "change_shop/1 returns a shop changeset", %{
      brand: %Brand{id: brand_id}
    } do
      %Shop{} = shop = shop_fixture(%{brand_id: brand_id})
      assert %Ecto.Changeset{} = Marketplaces.change_shop(shop)
    end
  end

  describe "brands" do
    alias ExCommerce.Accounts.User
    alias ExCommerce.AccountsFixtures
    alias ExCommerce.Marketplaces.{Brand, BrandUser}

    @valid_attrs %{name: "some name", slug: "some-name"}
    @update_attrs %{name: "some updated name", slug: "some-updated-name"}
    @invalid_attrs %{name: nil, slug: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, %Brand{} = brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Marketplaces.create_brand()

      brand
    end

    test "list_brands/0 returns all brands" do
      %Brand{} = brand = brand_fixture()
      assert Marketplaces.list_brands() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      %Brand{id: brand_id} = brand = brand_fixture()
      assert Marketplaces.get_brand!(brand_id) == brand
    end

    test "get_brand_by/2 returns the brand with the given slug" do
      %Brand{slug: slug} = brand = brand_fixture()
      assert Marketplaces.get_brand_by(:slug, slug) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      assert {:ok, %Brand{name: brand_name}} =
               Marketplaces.create_brand(@valid_attrs)

      assert brand_name == @valid_attrs.name
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.create_brand(@invalid_attrs)
    end

    test "assoc_user_brand/2 creates a brand and associates it to a user" do
      %User{id: user_id} = user = AccountsFixtures.user_fixture()

      assert {:ok,
              %{
                brand: %Brand{id: brand_id, name: brand_name} = brand,
                brand_user:
                  %BrandUser{
                    id: brand_user_id,
                    brand_id: brand_user_brand_id,
                    user_id: brand_user_user_id
                  } = brand_user
              }} = Marketplaces.assoc_user_brand(user, @valid_attrs)

      assert brand_name == @valid_attrs.name
      assert brand_id == brand_user_brand_id
      assert user_id == brand_user_user_id

      assert Marketplaces.get_brand!(brand_id) == brand
      assert Marketplaces.get_brand_user!(brand_user_id) == brand_user
    end

    test "assoc_user_brand/2 fails on invalid brand attributes" do
      %User{} = user = AccountsFixtures.user_fixture()

      assert {:error, :brand, changeset, %{}} =
               Marketplaces.assoc_user_brand(user, @invalid_attrs)

      refute changeset.valid?

      assert {"can't be blank", [validation: :required]} =
               Keyword.get(changeset.errors, :name)
    end

    test "assoc_user_brand/2 fails on invalid brand_user id" do
      %User{} = user = %User{id: Ecto.UUID.generate()}

      assert {:error, :brand_user, changeset, %{brand: %Brand{id: brand_id}}} =
               Marketplaces.assoc_user_brand(user, @valid_attrs)

      refute changeset.valid?

      assert {"does not exist",
              [
                constraint: :foreign,
                constraint_name: "brands_users_user_id_fkey"
              ]} = Keyword.get(changeset.errors, :user_id)

      assert_raise Ecto.NoResultsError, fn ->
        Marketplaces.get_brand!(brand_id)
      end
    end

    test "assoc_user_brand/2 fails on nil brand_user id" do
      %User{} = user = %User{id: nil}

      assert {:error, :brand_user, changeset, %{brand: %Brand{id: brand_id}}} =
               Marketplaces.assoc_user_brand(user, @valid_attrs)

      refute changeset.valid?

      assert {"can't be blank", [validation: :required]} =
               Keyword.get(changeset.errors, :user_id)

      assert_raise Ecto.NoResultsError, fn ->
        Marketplaces.get_brand!(brand_id)
      end
    end

    test "update_brand/2 with valid data updates the brand" do
      %Brand{} = brand = brand_fixture()

      assert {:ok, %Brand{name: brand_name}} =
               Marketplaces.update_brand(brand, @update_attrs)

      assert brand_name == @update_attrs.name
    end

    test "update_brand/2 with invalid data returns error changeset" do
      %Brand{id: brand_id} = brand = brand_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.update_brand(brand, @invalid_attrs)

      assert brand == Marketplaces.get_brand!(brand_id)
    end

    test "delete_brand/1 deletes the brand" do
      %Brand{id: brand_id} = brand = brand_fixture()
      assert {:ok, %Brand{}} = Marketplaces.delete_brand(brand)

      assert_raise Ecto.NoResultsError, fn ->
        Marketplaces.get_brand!(brand_id)
      end
    end

    test "change_brand/1 returns a brand changeset" do
      %Brand{} = brand = brand_fixture()
      assert %Ecto.Changeset{} = Marketplaces.change_brand(brand)
    end
  end

  describe "brands_users" do
    alias ExCommerce.Accounts.User
    alias ExCommerce.AccountsFixtures
    alias ExCommerce.BrandsFixtures
    alias ExCommerce.Marketplaces.{Brand, BrandUser}

    @valid_attrs %{is_owner: true}
    @update_attrs %{is_owner: false}
    @invalid_attrs %{is_owner: nil}

    def brand_user_fixture(attrs \\ %{}) do
      %Brand{id: brand_id} = BrandsFixtures.create()
      %User{id: user_id} = AccountsFixtures.user_fixture()

      {:ok, %BrandUser{} = brand_user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{user_id: user_id, brand_id: brand_id})
        |> Marketplaces.create_brand_user()

      brand_user
    end

    test "list_brands_users/0 returns all brands_users" do
      %BrandUser{} = brand_user = brand_user_fixture()
      assert Marketplaces.list_brands_users() == [brand_user]
    end

    test "get_brand_user!/1 returns the brand_user with given id" do
      %BrandUser{id: brand_user_id} = brand_user = brand_user_fixture()
      assert Marketplaces.get_brand_user!(brand_user_id) == brand_user
    end

    test "create_brand_user/1 with valid data creates a brand_user" do
      %User{id: user_id} = AccountsFixtures.user_fixture()
      %Brand{id: brand_id} = BrandsFixtures.create()

      valid_attrs =
        Map.merge(@valid_attrs, %{user_id: user_id, brand_id: brand_id})

      assert {:ok, %BrandUser{is_owner: is_owner}} =
               Marketplaces.create_brand_user(valid_attrs)

      assert is_owner == @valid_attrs.is_owner
    end

    test "create_brand_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.create_brand_user(@invalid_attrs)
    end

    test "update_brand_user/2 with valid data updates the brand_user" do
      %BrandUser{} = brand_user = brand_user_fixture()

      assert {:ok, %BrandUser{is_owner: is_owner}} =
               Marketplaces.update_brand_user(brand_user, @update_attrs)

      assert is_owner == @update_attrs.is_owner
    end

    test "update_brand_user/2 with invalid data returns error changeset" do
      %BrandUser{id: brand_user_id} = brand_user = brand_user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Marketplaces.update_brand_user(brand_user, @invalid_attrs)

      assert brand_user == Marketplaces.get_brand_user!(brand_user_id)
    end

    test "delete_brand_user/1 deletes the brand_user" do
      %BrandUser{id: brand_user_id} = brand_user = brand_user_fixture()
      assert {:ok, %BrandUser{}} = Marketplaces.delete_brand_user(brand_user)

      assert_raise Ecto.NoResultsError, fn ->
        Marketplaces.get_brand_user!(brand_user_id)
      end
    end

    test "change_brand_user/1 returns a brand_user changeset" do
      %BrandUser{} = brand_user = brand_user_fixture()
      assert %Ecto.Changeset{} = Marketplaces.change_brand_user(brand_user)
    end
  end
end
