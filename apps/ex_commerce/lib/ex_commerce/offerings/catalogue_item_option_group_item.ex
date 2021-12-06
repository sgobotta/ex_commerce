defmodule ExCommerce.Offerings.CatalogueItemOptionGroupItem do
  @moduledoc """
  The Catalogue Item Option Group / Item relationship schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{CatalogueItem, CatalogueItemOptionGroup}

  @fields [:visible]
  @foreign_fields [:catalogue_item_option_group_id, :catalogue_item_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_option_groups_items" do
    field :visible, :boolean, default: false

    belongs_to :catalogue_item_option_group, CatalogueItemOptionGroup
    belongs_to :catalogue_item, CatalogueItem

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_option_group_item, attrs) do
    catalogue_item_option_group_item
    |> cast(attrs, @fields ++ @foreign_fields)
    # |> cast_assoc(:catalogue_item_option_group_id)
    # |> cast_assoc(:catalogue_item_id)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
