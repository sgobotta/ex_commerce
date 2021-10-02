defmodule ExCommerce.Marketplaces do
  @moduledoc """
  The Marketplaces context.
  """

  import Ecto.Query, warn: false

  alias __MODULE__
  alias ExCommerce.Accounts.User
  alias ExCommerce.Marketplaces.Shop
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
  Creates a shop.

  ## Examples

      iex> create_shop(%{field: value})
      {:ok, %Shop{}}

      iex> create_shop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shop(attrs \\ %{}) do
    %Shop{}
    |> Shop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shop.

  ## Examples

      iex> update_shop(shop, %{field: new_value})
      {:ok, %Shop{}}

      iex> update_shop(shop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shop(%Shop{} = shop, attrs) do
    shop
    |> Shop.changeset(attrs)
    |> Repo.update()
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

  alias ExCommerce.Marketplaces.Brand

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

  def assoc_user_brand(%User{id: user_id}, brand_attrs) do
    Repo.transaction(fn ->
      {:ok, %Brand{id: brand_id} = brand} =
        Marketplaces.create_brand(brand_attrs)

      {:ok, %BrandUser{}} =
        Marketplaces.create_brand_user(%{user_id: user_id, brand_id: brand_id})

      brand
    end)
  end
end
