defmodule ExCommerce.Marketplaces do
  @moduledoc """
  The Marketplaces context.
  """

  import Ecto.Query, warn: false

  alias ExCommerce.Accounts.User
  alias ExCommerce.Marketplaces.{Brand, Shop}
  alias ExCommerce.Repo

  @doc """
  Returns the list of shops.

  ## Examples

      iex> list_shops()
      [%Shop{}, ...]

  """
  def list_shops do
    Repo.all(Shop)
  end

  @doc """
  Given a brand id returns a list of shops that belong to it.

  ## Examples

      iex> list_shops_by_brand("658e944a-e882-4318-8364-8abaffe7ce71")
      [%Shop{}, ...]

  """
  def list_shops_by_brand(brand_id) do
    from(s in Shop, where: s.brand_id == ^brand_id)
    |> Repo.all()
  end

  @doc """
  Returns a list of Shop that matches the given id list.

  ## Examples

      iex> list_shops_by_ids(["658e944a-e882-4318-8364-8abaffe7ce71"])
      [%Shop{}]

  """
  def list_shops_by_id(shop_ids) do
    Repo.all(
      from s in Shop,
        where: s.id in ^shop_ids
    )
  end

  @doc """
  Gets a single shop.

  Raises `Ecto.NoResultsError` if the Shop does not exist.

  ## Examples

      iex> get_shop!(123)
      %Shop{}

      iex> get_shop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shop!(id), do: Repo.get!(Shop, id)

  @doc """
  Takes a brand slug and a shop slug to return a Shop

  ## Examples

      iex> get_shop_by_brand_slug("some-brand-slug", "some-shop-slug")
      %Shop{}

      iex> get_shop_by_brand_slug(
      ...>  "some-invalid-brand-slug",
      ...>  "some-invalid-shop-slug"
      ...> )
      nil

  """
  @spec get_shop_by_brand_slug(binary(), binary()) :: %Shop{} | nil
  def get_shop_by_brand_slug(brand_slug, shop_slug) do
    query =
      from shop in Shop,
        join: brand in Brand,
        on: brand.slug == ^brand_slug,
        where: shop.slug == ^shop_slug

    Repo.one(query)
  end

  @doc """
  Creates a shop.

  ## Examples

      iex> create_shop(%{field: value})
      {:ok, %Shop{}}

      iex> create_shop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shop(attrs \\ %{}, after_save \\ &{:ok, &1}) do
    %Shop{}
    |> Shop.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
  end

  @doc """
  Updates a shop.

  ## Examples

      iex> update_shop(shop, %{field: new_value})
      {:ok, %Shop{}}

      iex> update_shop(shop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shop(%Shop{} = shop, attrs, after_save \\ &{:ok, &1}) do
    shop
    |> Shop.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
  end

  @doc """
  Deletes a shop.

  ## Examples

      iex> delete_shop(shop)
      {:ok, %Shop{}}

      iex> delete_shop(shop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shop(%Shop{} = shop) do
    Repo.delete(shop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shop changes.

  ## Examples

      iex> change_shop(shop)
      %Ecto.Changeset{data: %Shop{}}

  """
  def change_shop(%Shop{} = shop, attrs \\ %{}) do
    Shop.changeset(shop, attrs)
  end

  defp after_save({:ok, struct}, func), do: {:ok, _struct} = func.(struct)

  defp after_save(error, _func), do: error

  @doc """
  Returns the list of brands.

  ## Examples

      iex> list_brands()
      [%Brand{}, ...]

  """
  def list_brands do
    Repo.all(Brand)
  end

  @doc """
  Gets a single brand.

  Raises `Ecto.NoResultsError` if the Brand does not exist.

  ## Examples

      iex> get_brand!(123)
      %Brand{}

      iex> get_brand!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brand!(id), do: Repo.get!(Brand, id)

  @doc """
  Takes a valid brand field as a key and a value to return a Brand.

  ## Examples

      iex> get_brand_by(:slug, "some-name")
      %Brand{}

      iex> get_brand_by(:slug, "some-invalid-slug")
      nil

  """
  @spec get_brand_by(atom(), any()) :: %Brand{} | nil
  def get_brand_by(key, value) do
    Repo.get_by(Brand, [{key, value}])
  end

  @doc """
  Creates a brand.

  ## Examples

      iex> create_brand(%{field: value})
      {:ok, %Brand{}}

      iex> create_brand(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brand(attrs \\ %{}) do
    %Brand{}
    |> Brand.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brand.

  ## Examples

      iex> update_brand(brand, %{field: new_value})
      {:ok, %Brand{}}

      iex> update_brand(brand, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brand(%Brand{} = brand, attrs) do
    brand
    |> Brand.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a brand.

  ## Examples

      iex> delete_brand(brand)
      {:ok, %Brand{}}

      iex> delete_brand(brand)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brand(%Brand{} = brand) do
    Repo.delete(brand)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brand changes.

  ## Examples

      iex> change_brand(brand)
      %Ecto.Changeset{data: %Brand{}}

  """
  def change_brand(%Brand{} = brand, attrs \\ %{}) do
    Brand.changeset(brand, attrs)
  end

  alias ExCommerce.Marketplaces.BrandUser

  @doc """
  Returns the list of brands_users.

  ## Examples

      iex> list_brands_users()
      [%BrandUser{}, ...]

  """
  def list_brands_users do
    Repo.all(BrandUser)
  end

  @doc """
  Gets a single brand_user.

  Raises `Ecto.NoResultsError` if the Brand user does not exist.

  ## Examples

      iex> get_brand_user!(123)
      %BrandUser{}

      iex> get_brand_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brand_user!(id), do: Repo.get!(BrandUser, id)

  @doc """
  Creates a brand_user.

  ## Examples

      iex> create_brand_user(%{field: value})
      {:ok, %BrandUser{}}

      iex> create_brand_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brand_user(attrs \\ %{}) do
    %BrandUser{}
    |> BrandUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brand_user.

  ## Examples

      iex> update_brand_user(brand_user, %{field: new_value})
      {:ok, %BrandUser{}}

      iex> update_brand_user(brand_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brand_user(%BrandUser{} = brand_user, attrs) do
    brand_user
    |> BrandUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a brand_user.

  ## Examples

      iex> delete_brand_user(brand_user)
      {:ok, %BrandUser{}}

      iex> delete_brand_user(brand_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brand_user(%BrandUser{} = brand_user) do
    Repo.delete(brand_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brand_user changes.

  ## Examples

      iex> change_brand_user(brand_user)
      %Ecto.Changeset{data: %BrandUser{}}

  """
  def change_brand_user(%BrandUser{} = brand_user, attrs \\ %{}) do
    BrandUser.changeset(brand_user, attrs)
  end

  # ----------------------------------------------------------------------------
  # Associations

  @doc """
  Given a `user_id` and `brand_attrs`, attempts to create a `%Brand{}` and
  associate it with the given `user_id`. If there is an error, the whole
  operation should be aborted and no records should be created.

  ## Examples

      iex> assoc_user_brand(
        %User{id: Ecto.UUID.generate()},
        %{name: "some name"}}
      )
      {:ok, %{brand: %Brand{}, brand_user: %BrandUser{}}}

      iex> assoc_user_brand(
        %User{id: Ecto.UUID.generate()},
        %{name: nil}}
      )
      {:error, :brand,
        #Ecto.Changeset<
          action: :insert,
          changes: %{},
          errors: [name: {"can't be blank", [validation: :required]}],
          data: #ExCommerce.Marketplaces.Brand<>,
          valid?: false
        >, %{}}

  """
  def assoc_user_brand(%User{id: user_id}, brand_attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:brand, change_brand(%Brand{}, brand_attrs))
    |> Ecto.Multi.insert(:brand_user, fn %{brand: %Brand{id: brand_id}} ->
      change_brand_user(%BrandUser{}, %{user_id: user_id, brand_id: brand_id})
    end)
    |> Repo.transaction()
  end
end
