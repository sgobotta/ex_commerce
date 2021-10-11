defmodule ExCommerce.Offerings.CatalogueItemVariant do
  @moduledoc """
  The CatalogueItemVariant schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:type, :price]
  @foreign_fields [:catalogue_item_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_variants" do
    field :price, :decimal
    field :type, :string

    belongs_to :catalogue_item,
               ExCommerce.Offerings.CatalogueItem,
               type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_variant, attrs) do
    catalogue_item_variant
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
