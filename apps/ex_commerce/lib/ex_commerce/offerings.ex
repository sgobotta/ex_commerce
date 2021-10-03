defmodule ExCommerce.Offerings do
  @moduledoc """
  The Offerings context.
  """

  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Offerings.Catalogue

  @doc """
  Returns the list of catalogues.

  ## Examples

      iex> list_catalogues()
      [%Catalogue{}, ...]

  """
  def list_catalogues do
    Repo.all(Catalogue)
  end

  @doc """
  Given a brand id returns a list of catalogues that belong to it.

  ## Examples

      iex> list_catalogues_by_brand("658e944a-e882-4318-8364-8abaffe7ce71")
      [%Catalogue{}, ...]

  """
  def list_catalogues_by_brand(brand_id) do
    from(s in Catalogue, where: s.brand_id == ^brand_id)
    |> Repo.all()
  end

  @doc """
  Gets a single catalogue.

  Raises `Ecto.NoResultsError` if the Catalogue does not exist.

  ## Examples

      iex> get_catalogue!(123)
      %Catalogue{}

      iex> get_catalogue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue!(id), do: Repo.get!(Catalogue, id)

  @doc """
  Creates a catalogue.

  ## Examples

      iex> create_catalogue(%{field: value})
      {:ok, %Catalogue{}}

      iex> create_catalogue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue(attrs \\ %{}) do
    %Catalogue{}
    |> Catalogue.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue.

  ## Examples

      iex> update_catalogue(catalogue, %{field: new_value})
      {:ok, %Catalogue{}}

      iex> update_catalogue(catalogue, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue(%Catalogue{} = catalogue, attrs) do
    catalogue
    |> Catalogue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue.

  ## Examples

      iex> delete_catalogue(catalogue)
      {:ok, %Catalogue{}}

      iex> delete_catalogue(catalogue)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue(%Catalogue{} = catalogue) do
    Repo.delete(catalogue)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue changes.

  ## Examples

      iex> change_catalogue(catalogue)
      %Ecto.Changeset{data: %Catalogue{}}

  """
  def change_catalogue(%Catalogue{} = catalogue, attrs \\ %{}) do
    Catalogue.changeset(catalogue, attrs)
  end
end
