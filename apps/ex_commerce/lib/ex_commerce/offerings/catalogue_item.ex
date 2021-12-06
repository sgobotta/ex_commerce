defmodule ExCommerce.Offerings.CatalogueItem do
  @moduledoc """
  The CatalogueCategory schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ExCommerce.Offerings.{
    CatalogueItemOptionGroup,
    CatalogueItemOptionGroupItem,
    CatalogueItemVariant
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
      join_through: CatalogueItemOptionGroupItem

    timestamps()
  end

  @doc false
  def changeset(catalogue_item, attrs) do
    catalogue_item
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:variants)
    |> cast_assoc(:option_groups)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
