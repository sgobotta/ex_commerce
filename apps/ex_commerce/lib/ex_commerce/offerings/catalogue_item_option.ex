defmodule ExCommerce.Offerings.CatalogueItemOption do
  @moduledoc """
  The CatalogueItemOption schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{CatalogueItem, CatalogueItemVariant}

  @fields [:price_modifier, :is_visible]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_options" do
    field :is_visible, :boolean, default: false
    field :price_modifier, :decimal
    field :brand_id, :binary_id

    belongs_to :catalogue_item, CatalogueItem, type: :binary_id
    belongs_to :catalogue_item_variant, CatalogueItemVariant, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_option, attrs) do
    catalogue_item_option
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:catalogue_item)
    |> cast_assoc(:catalogue_item_variant)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
