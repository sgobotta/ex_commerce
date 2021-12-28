defmodule ExCommerce.Offerings.Relations.CatalogueCategoryItem do
  @moduledoc """
  The CatalogueCategory / CatalogueItem schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{CatalogueCategory, CatalogueItem}

  @fields [:visible]
  @foreign_fields [:category_id, :item_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_categories_items" do
    field :visible, :boolean, default: false

    belongs_to :category, CatalogueCategory
    belongs_to :item, CatalogueItem

    timestamps()
  end

  @doc false
  def changeset(catalogue_category_item, attrs) do
    catalogue_category_item
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:category)
    |> cast_assoc(:item)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
