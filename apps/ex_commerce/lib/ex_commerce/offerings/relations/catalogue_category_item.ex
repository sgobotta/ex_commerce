defmodule ExCommerce.Offerings.Relations.CatalogueCategoryItem do
  @moduledoc """
  The CatalogueCategory / CatalogueItem schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{CatalogueCategory, CatalogueItem}

  @fields [:visible]
  @foreign_fields [:catalogue_category_id, :catalogue_item_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_categories_items" do
    field :visible, :boolean, default: false

    belongs_to :catalogue_category, CatalogueCategory
    belongs_to :catalogue_item, CatalogueItem

    timestamps()
  end

  @doc false
  def changeset(catalogue_category_item, attrs) do
    catalogue_category_item
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:catalogue_category)
    |> cast_assoc(:catalogue_item)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
