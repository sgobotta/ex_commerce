defmodule ExCommerce.Offerings.CatalogueCategory do
  @moduledoc """
  The CatalogueCategory schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.CatalogueItem

  alias ExCommerce.Offerings.Relations.CatalogueCategoryItem

  @fields [:code, :name, :description]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_categories" do
    field :code, :string
    field :description, :string
    field :name, :string
    field :brand_id, :binary_id

    many_to_many :items, CatalogueItem,
      join_through: CatalogueCategoryItem,
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(catalogue_category, attrs) do
    catalogue_category
    |> cast(attrs, @fields ++ @foreign_fields)
    |> maybe_assoc_items(attrs)
    |> validate_required(@fields ++ @foreign_fields)
  end

  defp maybe_assoc_items(
         changeset,
         %{"items" => item_ids}
       ) do
    items = Offerings.filter_catalogue_items_by_id(item_ids)

    put_assoc(changeset, :items, items)
  end

  defp maybe_assoc_items(changeset, params)
       when not is_map_key(params, "items") do
    put_assoc(changeset, :items, [])
  end
end
