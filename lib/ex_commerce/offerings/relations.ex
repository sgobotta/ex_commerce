defmodule ExCommerce.Offerings.Relations do
  @moduledoc """
  The Offerings.Relations context.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Offerings.Relations.CatalogueCategoryItem

  @spec list_catalogue_categories_items :: list(CatalogueCategoryItem)
  @doc """
  Returns the list of catalogue_categories_items.

  ## Examples

      iex> list_catalogue_categories_items()
      [%CatalogueCategoryItem{}, ...]

  """
  def list_catalogue_categories_items do
    Repo.all(CatalogueCategoryItem)
  end

  @spec get_catalogue_category_item!(binary()) :: CatalogueCategoryItem
  @doc """
  Gets a single catalogue_category_item.

  Raises `Ecto.NoResultsError` if the Catalogue category item does not exist.

  ## Examples

      iex> get_catalogue_category_item!(123)
      %CatalogueCategoryItem{}

      iex> get_catalogue_category_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_category_item!(id), do: Repo.get!(CatalogueCategoryItem, id)

  @spec create_catalogue_category_item(map()) ::
          {:ok, CatalogueCategoryItem} | {:error, Ecto.Changeset.t()}
  @doc """
  Creates a catalogue_category_item.

  ## Examples

      iex> create_catalogue_category_item(%{field: value})
      {:ok, %CatalogueCategoryItem{}}

      iex> create_catalogue_category_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_category_item(attrs \\ %{}) do
    %CatalogueCategoryItem{}
    |> CatalogueCategoryItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_category_item.

  ## Examples

      iex> update_catalogue_category_item(catalogue_category_item, %{field: new_value})
      {:ok, %CatalogueCategoryItem{}}

      iex> update_catalogue_category_item(catalogue_category_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_category_item(
        %CatalogueCategoryItem{} = catalogue_category_item,
        attrs
      ) do
    catalogue_category_item
    |> CatalogueCategoryItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_category_item.

  ## Examples

      iex> delete_catalogue_category_item(catalogue_category_item)
      {:ok, %CatalogueCategoryItem{}}

      iex> delete_catalogue_category_item(catalogue_category_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_category_item(
        %CatalogueCategoryItem{} = catalogue_category_item
      ) do
    Repo.delete(catalogue_category_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_category_item changes.

  ## Examples

      iex> change_catalogue_category_item(catalogue_category_item)
      %Ecto.Changeset{data: %CatalogueCategoryItem{}}

  """
  def change_catalogue_category_item(
        %CatalogueCategoryItem{} = catalogue_category_item,
        attrs \\ %{}
      ) do
    CatalogueCategoryItem.changeset(catalogue_category_item, attrs)
  end

  alias ExCommerce.Offerings.Relations.CatalogueCategory

  @spec list_catalogues_categories :: list(CatalogueCategory)
  @doc """
  Returns the list of catalogues_categories.

  ## Examples

      iex> list_catalogues_categories()
      [%CatalogueCategory{}, ...]

  """
  def list_catalogues_categories do
    Repo.all(CatalogueCategory)
  end

  @spec get_catalogue_category!(binary()) :: CatalogueCategory
  @doc """
  Gets a single catalogue_category.

  Raises `Ecto.NoResultsError` if the Catalogue category does not exist.

  ## Examples

      iex> get_catalogue_category!(123)
      %CatalogueCategory{}

      iex> get_catalogue_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_category!(id), do: Repo.get!(CatalogueCategory, id)

  @spec create_catalogue_category(map()) ::
          {:ok, CatalogueCategory} | {:error, Ecto.Changeset.t()}
  @doc """
  Creates a catalogue_category.

  ## Examples

      iex> create_catalogue_category(%{field: value})
      {:ok, %CatalogueCategory{}}

      iex> create_catalogue_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_category(attrs \\ %{}) do
    %CatalogueCategory{}
    |> CatalogueCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_category.

  ## Examples

      iex> update_catalogue_category(catalogue_category, %{field: new_value})
      {:ok, %CatalogueCategory{}}

      iex> update_catalogue_category(catalogue_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_category(
        %CatalogueCategory{} = catalogue_category,
        attrs
      ) do
    catalogue_category
    |> CatalogueCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_category.

  ## Examples

      iex> delete_catalogue_category(catalogue_category)
      {:ok, %CatalogueCategory{}}

      iex> delete_catalogue_category(catalogue_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_category(%CatalogueCategory{} = catalogue_category) do
    Repo.delete(catalogue_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_category changes.

  ## Examples

      iex> change_catalogue_category(catalogue_category)
      %Ecto.Changeset{data: %CatalogueCategory{}}

  """
  def change_catalogue_category(
        %CatalogueCategory{} = catalogue_category,
        attrs \\ %{}
      ) do
    CatalogueCategory.changeset(catalogue_category, attrs)
  end

  alias ExCommerce.Offerings.Relations.ShopCatalogue

  @doc """
  Returns the list of shops_catalogues.

  ## Examples

      iex> list_shops_catalogues()
      [%ShopCatalogue{}, ...]

  """
  def list_shops_catalogues do
    Repo.all(ShopCatalogue)
  end

  @doc """
  Gets a single shop_catalogue.

  Raises `Ecto.NoResultsError` if the Shop catalogue does not exist.

  ## Examples

      iex> get_shop_catalogue!(123)
      %ShopCatalogue{}

      iex> get_shop_catalogue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shop_catalogue!(id), do: Repo.get!(ShopCatalogue, id)

  @doc """
  Creates a shop_catalogue.

  ## Examples

      iex> create_shop_catalogue(%{field: value})
      {:ok, %ShopCatalogue{}}

      iex> create_shop_catalogue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shop_catalogue(attrs \\ %{}) do
    %ShopCatalogue{}
    |> ShopCatalogue.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shop_catalogue.

  ## Examples

      iex> update_shop_catalogue(shop_catalogue, %{field: new_value})
      {:ok, %ShopCatalogue{}}

      iex> update_shop_catalogue(shop_catalogue, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shop_catalogue(%ShopCatalogue{} = shop_catalogue, attrs) do
    shop_catalogue
    |> ShopCatalogue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shop_catalogue.

  ## Examples

      iex> delete_shop_catalogue(shop_catalogue)
      {:ok, %ShopCatalogue{}}

      iex> delete_shop_catalogue(shop_catalogue)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shop_catalogue(%ShopCatalogue{} = shop_catalogue) do
    Repo.delete(shop_catalogue)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shop_catalogue changes.

  ## Examples

      iex> change_shop_catalogue(shop_catalogue)
      %Ecto.Changeset{data: %ShopCatalogue{}}

  """
  def change_shop_catalogue(%ShopCatalogue{} = shop_catalogue, attrs \\ %{}) do
    ShopCatalogue.changeset(shop_catalogue, attrs)
  end
end
