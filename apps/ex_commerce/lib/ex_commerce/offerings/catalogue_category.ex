defmodule ExCommerce.Offerings.CatalogueCategory do
  @moduledoc """
  The CatalogueCategory schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.{
    EctoHelpers,
    Offerings
  }

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueItem,
    Relations
  }

  @fields [:code, :name, :description]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_categories" do
    field :code, :string
    field :description, :string
    field :name, :string
    field :brand_id, :binary_id

    many_to_many :catalogues, Catalogue,
      join_through: Relations.CatalogueCategory,
      on_replace: :delete,
      on_delete: :delete_all

    many_to_many :items, CatalogueItem,
      join_through: Relations.CatalogueCategoryItem,
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(catalogue_category, attrs) do
    catalogue_category
    |> cast(attrs, @fields ++ @foreign_fields)
    |> EctoHelpers.put_assoc(
      attrs,
      :items,
      &Offerings.filter_catalogue_items_by_id/1
    )
    |> EctoHelpers.put_assoc(
      attrs,
      :catalogues,
      &Offerings.filter_catalogues_by_id/1
    )
    |> validate_required(@fields ++ @foreign_fields)
  end
end
