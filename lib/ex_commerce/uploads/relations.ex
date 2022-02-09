defmodule ExCommerce.Uploads.Relations do
  @moduledoc """
  The Uploads.Relations context.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Uploads.Relations.CatalogueItemPhoto

  @doc """
  Returns the list of catalogue_items_photos.

  ## Examples

      iex> list_catalogue_items_photos()
      [%CatalogueItemPhoto{}, ...]

  """
  def list_catalogue_items_photos do
    Repo.all(CatalogueItemPhoto)
  end

  @doc """
  Gets a single catalogue_item_photo.

  Raises `Ecto.NoResultsError` if the Catalogue item photo does not exist.

  ## Examples

      iex> get_catalogue_item_photo!(123)
      %CatalogueItemPhoto{}

      iex> get_catalogue_item_photo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_item_photo!(id), do: Repo.get!(CatalogueItemPhoto, id)

  @doc """
  Creates a catalogue_item_photo.

  ## Examples

      iex> create_catalogue_item_photo(%{field: value})
      {:ok, %CatalogueItemPhoto{}}

      iex> create_catalogue_item_photo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_item_photo(attrs \\ %{}) do
    %CatalogueItemPhoto{}
    |> CatalogueItemPhoto.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_item_photo.

  ## Examples

      iex> update_catalogue_item_photo(catalogue_item_photo, %{field: new_value})
      {:ok, %CatalogueItemPhoto{}}

      iex> update_catalogue_item_photo(catalogue_item_photo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_item_photo(
        %CatalogueItemPhoto{} = catalogue_item_photo,
        attrs
      ) do
    catalogue_item_photo
    |> CatalogueItemPhoto.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_item_photo.

  ## Examples

      iex> delete_catalogue_item_photo(catalogue_item_photo)
      {:ok, %CatalogueItemPhoto{}}

      iex> delete_catalogue_item_photo(catalogue_item_photo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_item_photo(%CatalogueItemPhoto{} = catalogue_item_photo) do
    Repo.delete(catalogue_item_photo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_item_photo changes.

  ## Examples

      iex> change_catalogue_item_photo(catalogue_item_photo)
      %Ecto.Changeset{data: %CatalogueItemPhoto{}}

  """
  def change_catalogue_item_photo(
        %CatalogueItemPhoto{} = catalogue_item_photo,
        attrs \\ %{}
      ) do
    CatalogueItemPhoto.changeset(catalogue_item_photo, attrs)
  end
end
