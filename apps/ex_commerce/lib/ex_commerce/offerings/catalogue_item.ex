defmodule ExCommerce.Offerings.CatalogueItem do
  @moduledoc """
  The CatalogueCategory schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    CatalogueCategory,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  alias ExCommerce.Offerings.Relations.{
    CatalogueCategoryItem,
    CatalogueItemOptionGroupItem
  }

  @fields [:code, :name, :description]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_items" do
    field :code, :string
    field :description, :string
    field :name, :string
    field :brand_id, :binary_id

    has_many :variants, CatalogueItemVariant, on_delete: :delete_all

    many_to_many :option_groups, CatalogueItemOptionGroup,
      join_through: CatalogueItemOptionGroupItem,
      on_replace: :delete,
      on_delete: :delete_all

    many_to_many :categories, CatalogueCategory,
      join_through: CatalogueCategoryItem,
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(catalogue_item, attrs) do
    catalogue_item
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:variants)
    |> maybe_assoc_option_groups(attrs)
    |> maybe_assoc_categories(attrs)
    |> validate_required(@fields ++ @foreign_fields)
  end

  defp maybe_assoc_option_groups(
         changeset,
         %{"option_groups" => option_group_ids}
       ) do
    option_groups =
      Offerings.filter_catalogue_item_option_groups_by_id(option_group_ids)

    put_assoc(changeset, :option_groups, option_groups)
  end

  defp maybe_assoc_option_groups(changeset, params)
       when not is_map_key(params, "option_groups") do
    put_assoc(changeset, :option_groups, [])
  end

  defp maybe_assoc_option_groups(changeset, _params), do: changeset

  defp maybe_assoc_categories(
         changeset,
         %{"categories" => category_ids}
       ) do
    categories = Offerings.filter_catalogue_categories_by_id(category_ids)

    put_assoc(changeset, :categories, categories)
  end

  defp maybe_assoc_categories(changeset, params)
       when not is_map_key(params, "categories") do
    put_assoc(changeset, :categories, [])
  end

  defp maybe_assoc_categories(changeset, _params), do: changeset
end
