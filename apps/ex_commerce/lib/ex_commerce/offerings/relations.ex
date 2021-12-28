defmodule ExCommerce.Offerings.Relations do
  @moduledoc """
  The Offerings.Relations context.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Offerings.Relations.CatalogueCategoryItem

  @doc """
  Returns the list of catalogue_categories_items.

  ## Examples

      iex> list_catalogue_categories_items()
      [%CatalogueCategoryItem{}, ...]

  """
  def list_catalogue_categories_items do
    Repo.all(CatalogueCategoryItem)
  end

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
end
