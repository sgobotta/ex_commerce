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

  alias ExCommerce.Offerings.CatalogueCategory

  @doc """
  Returns the list of catalogue_categories.

  ## Examples

      iex> list_catalogue_categories()
      [%CatalogueCategory{}, ...]

  """
  def list_catalogue_categories do
    Repo.all(CatalogueCategory)
  end

  @doc """
  Given a brand id returns a list of catalogue categories that belong to it.

  ## Examples

      iex> list_catalogue_categories_by_brand("658e944a-e882-4318-8364-8abaffe7ce71")
      [%CatalogueCategory{}, ...]

  """
  def list_catalogue_categories_by_brand(brand_id) do
    from(s in CatalogueCategory, where: s.brand_id == ^brand_id)
    |> Repo.all()
  end

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

  alias ExCommerce.Offerings.CatalogueItem

  @doc """
  Returns the list of catalogue_items.

  ## Examples

      iex> list_catalogue_items()
      [%CatalogueItem{}, ...]

  """
  def list_catalogue_items do
    Repo.all(CatalogueItem)
  end

  @doc """
  Given a brand id returns a list of catalogue items that belong to it.

  ## Examples

      iex> list_catalogue_items_by_brand("658e944a-e882-4318-8364-8abaffe7ce71")
      [%CatalogueItem{}, ...]

  """
  def list_catalogue_items_by_brand(brand_id) do
    from(s in CatalogueItem, where: s.brand_id == ^brand_id)
    |> Repo.all()
  end

  @doc """
  Gets a single catalogue_item.

  Raises `Ecto.NoResultsError` if the Catalogue item does not exist.

  ## Examples

      iex> get_catalogue_item!(123)
      %CatalogueItem{}

      iex> get_catalogue_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_item!(id), do: Repo.get!(CatalogueItem, id)

  @doc """
  Creates a catalogue_item.

  ## Examples

      iex> create_catalogue_item(%{field: value})
      {:ok, %CatalogueItem{}}

      iex> create_catalogue_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_item(attrs \\ %{}) do
    %CatalogueItem{}
    |> CatalogueItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_item.

  ## Examples

      iex> update_catalogue_item(catalogue_item, %{field: new_value})
      {:ok, %CatalogueItem{}}

      iex> update_catalogue_item(catalogue_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_item(%CatalogueItem{} = catalogue_item, attrs) do
    catalogue_item
    |> CatalogueItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_item.

  ## Examples

      iex> delete_catalogue_item(catalogue_item)
      {:ok, %CatalogueItem{}}

      iex> delete_catalogue_item(catalogue_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_item(%CatalogueItem{} = catalogue_item) do
    Repo.delete(catalogue_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_item changes.

  ## Examples

      iex> change_catalogue_item(catalogue_item)
      %Ecto.Changeset{data: %CatalogueItem{}}

  """
  def change_catalogue_item(%CatalogueItem{} = catalogue_item, attrs \\ %{}) do
    CatalogueItem.changeset(catalogue_item, attrs)
  end

  alias ExCommerce.Offerings.CatalogueItemVariant

  @doc """
  Returns the list of catalogue_item_variants.

  ## Examples

      iex> list_catalogue_item_variants()
      [%CatalogueItemVariant{}, ...]

  """
  def list_catalogue_item_variants do
    Repo.all(CatalogueItemVariant)
  end

  @doc """
  Gets a single catalogue_item_variant.

  Raises `Ecto.NoResultsError` if the Catalogue item variant does not exist.

  ## Examples

      iex> get_catalogue_item_variant!(123)
      %CatalogueItemVariant{}

      iex> get_catalogue_item_variant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_item_variant!(id), do: Repo.get!(CatalogueItemVariant, id)

  @doc """
  Creates a catalogue_item_variant.

  ## Examples

      iex> create_catalogue_item_variant(%{field: value})
      {:ok, %CatalogueItemVariant{}}

      iex> create_catalogue_item_variant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_item_variant(attrs \\ %{}) do
    %CatalogueItemVariant{}
    |> CatalogueItemVariant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_item_variant.

  ## Examples

      iex> update_catalogue_item_variant(catalogue_item_variant, %{field: new_value})
      {:ok, %CatalogueItemVariant{}}

      iex> update_catalogue_item_variant(catalogue_item_variant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_item_variant(
        %CatalogueItemVariant{} = catalogue_item_variant,
        attrs
      ) do
    catalogue_item_variant
    |> CatalogueItemVariant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_item_variant.

  ## Examples

      iex> delete_catalogue_item_variant(catalogue_item_variant)
      {:ok, %CatalogueItemVariant{}}

      iex> delete_catalogue_item_variant(catalogue_item_variant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_item_variant(
        %CatalogueItemVariant{} = catalogue_item_variant
      ) do
    Repo.delete(catalogue_item_variant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_item_variant changes.

  ## Examples

      iex> change_catalogue_item_variant(catalogue_item_variant)
      %Ecto.Changeset{data: %CatalogueItemVariant{}}

  """
  def change_catalogue_item_variant(
        %CatalogueItemVariant{} = catalogue_item_variant,
        attrs \\ %{}
      ) do
    CatalogueItemVariant.changeset(catalogue_item_variant, attrs)
  end

  # ----------------------------------------------------------------------------
  # Associations

  @doc """
  Given a `catalogue_item_id` and `catalogue_item_variant_attrs`, attempts to
  create a `%CatalogueItemVariant{}` and associate it with the given
  `catalogue_item_id`. If there is an error, the whole operation should be
  aborted and no records should be created.

  ## Examples

      iex> create_assoc_catalogue_item(
      ...>  {
      ...>   %CatalogueItem{},
      ...>   %{
      ...>     brand_id: Ecto.UUID.generate(),
      ...>     code: "some code",
      ...>     description: "some description",
      ...>     name: "some name"
      ...>   }
      ...>  },
      ...>  [
      ...>    {
      ...>      %CatalogueItemVariant{},
      ...>      %{
      ...>         id: Ecto.UUID.generate(),
      ...>         type: "some type",
      ...>         price: Decimal.new("4.20")
      ...>       }
      ...>    }
      ...>  ]
      ...> )
      {:ok,
        %{
          :catalogue_item => %CatalogueItem{},
          {:catalogue_item_variant, item_variant_id} => %CatalogueItemVariant{}
        }
      }

      iex> create_assoc_catalogue_item(
      ...>  {
      ...>    %CatalogueItem{},
      ...>    %{
      ...>       brand_id: Ecto.UUID.generate(),
      ...>       code: "some code",
      ...>       description: "some description",
      ...>       name: nil
      ...>     }
      ...>  },
      ...>  []
      ...> )
      {:error, :catalogue_item,
        #Ecto.Changeset<
          action: :insert,
          changes: %{brand_id: "f1bbfcdb-8035-4a45-bc25-1b313065d0d4"},
          errors: [name: {"can't be blank", [validation: :required]}],
          data: #ExCommerce.Offerings.CatalogueItem<>,
          valid?: false
        >, %{}}

      iex> create_assoc_catalogue_item(
      ...>  {
      ...>    %CatalogueItem{},
      ...>    %{
      ...>       brand_id: Ecto.UUID.generate(),
      ...>       code: "some code",
      ...>       description: "some description",
      ...>       name: "some name"
      ...>     }
      ...>  }
      ...>  [{%CatalogueItemVariant{}, %{type: "some type"}}]
      ...> )
      {:error, {:catalogue_item_variant, nil},
        #Ecto.Changeset<
          action: :insert,
          changes: %{catalogue_item_id: "5bf1015c-a5cc-47a6-9d88-c33a46677566"},
          errors: [price: {"can't be blank", [validation: :required]}],
          data: #ExCommerce.Offerings.CatalogueItemVariant<>,
          valid?: false
        >, %{catalogue_item: %CatalogueItem{}}}

  """
  def create_assoc_catalogue_item(
        {%CatalogueItem{} = catalogue_item_struct, catalogue_item_attrs},
        catalogue_item_variants_attrs
      ) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(
      :catalogue_item,
      change_catalogue_item(catalogue_item_struct, catalogue_item_attrs)
    )
    |> Ecto.Multi.merge(fn %{
                             catalogue_item: %CatalogueItem{
                               id: catalogue_item_id
                             }
                           } ->
      Enum.reduce(
        Enum.with_index(catalogue_item_variants_attrs),
        Ecto.Multi.new(),
        fn {{catalogue_item_variant_struct, catalogue_item_variant_attrs},
            index},
           acc ->
          Ecto.Multi.insert_or_update(
            acc,
            {:catalogue_item_variant, index},
            change_catalogue_item_variant(
              catalogue_item_variant_struct,
              Map.merge(
                %{catalogue_item_id: catalogue_item_id},
                catalogue_item_variant_attrs
              )
            )
          )
        end
      )
    end)
    |> Repo.transaction()
  end

  alias ExCommerce.Offerings.CatalogueItemOption

  @doc """
  Returns the list of catalogue_item_options.

  ## Examples

      iex> list_catalogue_item_options()
      [%CatalogueItemOption{}, ...]

  """
  def list_catalogue_item_options do
    Repo.all(CatalogueItemOption)
  end

  @doc """
  Gets a single catalogue_item_option.

  Raises `Ecto.NoResultsError` if the Catalogue item option does not exist.

  ## Examples

      iex> get_catalogue_item_option!(123)
      %CatalogueItemOption{}

      iex> get_catalogue_item_option!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_item_option!(id), do: Repo.get!(CatalogueItemOption, id)

  @doc """
  Creates a catalogue_item_option.

  ## Examples

      iex> create_catalogue_item_option(%{field: value})
      {:ok, %CatalogueItemOption{}}

      iex> create_catalogue_item_option(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_item_option(attrs \\ %{}) do
    %CatalogueItemOption{}
    |> CatalogueItemOption.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_item_option.

  ## Examples

      iex> update_catalogue_item_option(catalogue_item_option, %{field: new_value})
      {:ok, %CatalogueItemOption{}}

      iex> update_catalogue_item_option(catalogue_item_option, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_item_option(
        %CatalogueItemOption{} = catalogue_item_option,
        attrs
      ) do
    catalogue_item_option
    |> CatalogueItemOption.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_item_option.

  ## Examples

      iex> delete_catalogue_item_option(catalogue_item_option)
      {:ok, %CatalogueItemOption{}}

      iex> delete_catalogue_item_option(catalogue_item_option)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_item_option(
        %CatalogueItemOption{} = catalogue_item_option
      ) do
    Repo.delete(catalogue_item_option)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_item_option changes.

  ## Examples

      iex> change_catalogue_item_option(catalogue_item_option)
      %Ecto.Changeset{data: %CatalogueItemOption{}}

  """
  def change_catalogue_item_option(
        %CatalogueItemOption{} = catalogue_item_option,
        attrs \\ %{}
      ) do
    CatalogueItemOption.changeset(catalogue_item_option, attrs)
  end

  alias ExCommerce.Offerings.CatalogueItemOptionGroup

  @doc """
  Returns the list of catalogue_item_option_groups.

  ## Examples

      iex> list_catalogue_item_option_groups()
      [%CatalogueItemOptionGroup{}, ...]

  """
  def list_catalogue_item_option_groups do
    Repo.all(CatalogueItemOptionGroup)
  end

  @doc """
  Gets a single catalogue_item_option_group.

  Raises `Ecto.NoResultsError` if the Catalogue item option group does not exist.

  ## Examples

      iex> get_catalogue_item_option_group!(123)
      %CatalogueItemOptionGroup{}

      iex> get_catalogue_item_option_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_item_option_group!(id),
    do: Repo.get!(CatalogueItemOptionGroup, id)

  @doc """
  Creates a catalogue_item_option_group.

  ## Examples

      iex> create_catalogue_item_option_group(%{field: value})
      {:ok, %CatalogueItemOptionGroup{}}

      iex> create_catalogue_item_option_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_item_option_group(attrs \\ %{}) do
    %CatalogueItemOptionGroup{}
    |> CatalogueItemOptionGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_item_option_group.

  ## Examples

      iex> update_catalogue_item_option_group(catalogue_item_option_group, %{field: new_value})
      {:ok, %CatalogueItemOptionGroup{}}

      iex> update_catalogue_item_option_group(catalogue_item_option_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_item_option_group(
        %CatalogueItemOptionGroup{} = catalogue_item_option_group,
        attrs
      ) do
    catalogue_item_option_group
    |> CatalogueItemOptionGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_item_option_group.

  ## Examples

      iex> delete_catalogue_item_option_group(catalogue_item_option_group)
      {:ok, %CatalogueItemOptionGroup{}}

      iex> delete_catalogue_item_option_group(catalogue_item_option_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_item_option_group(
        %CatalogueItemOptionGroup{} = catalogue_item_option_group
      ) do
    Repo.delete(catalogue_item_option_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_item_option_group changes.

  ## Examples

      iex> change_catalogue_item_option_group(catalogue_item_option_group)
      %Ecto.Changeset{data: %CatalogueItemOptionGroup{}}

  """
  def change_catalogue_item_option_group(
        %CatalogueItemOptionGroup{} = catalogue_item_option_group,
        attrs \\ %{}
      ) do
    CatalogueItemOptionGroup.changeset(catalogue_item_option_group, attrs)
  end

  alias ExCommerce.Offerings.CatalogueItemOptionGroupItem

  @doc """
  Returns the list of catalogue_item_option_groups_items.

  ## Examples

      iex> list_catalogue_item_option_groups_items()
      [%CatalogueItemOptionGroupItem{}, ...]

  """
  def list_catalogue_item_option_groups_items do
    Repo.all(CatalogueItemOptionGroupItem)
  end

  @doc """
  Gets a single catalogue_item_option_group_item.

  Raises `Ecto.NoResultsError` if the Catalogue item option group item does not exist.

  ## Examples

      iex> get_catalogue_item_option_group_item!(123)
      %CatalogueItemOptionGroupItem{}

      iex> get_catalogue_item_option_group_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalogue_item_option_group_item!(id),
    do: Repo.get!(CatalogueItemOptionGroupItem, id)

  @doc """
  Creates a catalogue_item_option_group_item.

  ## Examples

      iex> create_catalogue_item_option_group_item(%{field: value})
      {:ok, %CatalogueItemOptionGroupItem{}}

      iex> create_catalogue_item_option_group_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalogue_item_option_group_item(attrs \\ %{}) do
    %CatalogueItemOptionGroupItem{}
    |> CatalogueItemOptionGroupItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalogue_item_option_group_item.

  ## Examples

      iex> update_catalogue_item_option_group_item(catalogue_item_option_group_item, %{field: new_value})
      {:ok, %CatalogueItemOptionGroupItem{}}

      iex> update_catalogue_item_option_group_item(catalogue_item_option_group_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalogue_item_option_group_item(
        %CatalogueItemOptionGroupItem{} = catalogue_item_option_group_item,
        attrs
      ) do
    catalogue_item_option_group_item
    |> CatalogueItemOptionGroupItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalogue_item_option_group_item.

  ## Examples

      iex> delete_catalogue_item_option_group_item(catalogue_item_option_group_item)
      {:ok, %CatalogueItemOptionGroupItem{}}

      iex> delete_catalogue_item_option_group_item(catalogue_item_option_group_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalogue_item_option_group_item(
        %CatalogueItemOptionGroupItem{} = catalogue_item_option_group_item
      ) do
    Repo.delete(catalogue_item_option_group_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalogue_item_option_group_item changes.

  ## Examples

      iex> change_catalogue_item_option_group_item(catalogue_item_option_group_item)
      %Ecto.Changeset{data: %CatalogueItemOptionGroupItem{}}

  """
  def change_catalogue_item_option_group_item(
        %CatalogueItemOptionGroupItem{} = catalogue_item_option_group_item,
        attrs \\ %{}
      ) do
    CatalogueItemOptionGroupItem.changeset(
      catalogue_item_option_group_item,
      attrs
    )
  end
end
