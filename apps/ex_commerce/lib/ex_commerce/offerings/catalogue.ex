defmodule ExCommerce.Offerings.Catalogue do
  @moduledoc """
  The Catalogue schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.{
    EctoHelpers,
    Offerings
  }

  alias ExCommerce.Offerings.{
    CatalogueCategory,
    Relations
  }

  @fields [:name, :code]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogues" do
    field :name, :string
    field :code, :string
    field :brand_id, :binary_id

    many_to_many :categories, CatalogueCategory,
      join_through: Relations.CatalogueCategory,
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(catalogue, attrs) do
    catalogue
    |> cast(attrs, @fields ++ @foreign_fields)
    |> EctoHelpers.put_assoc(
      attrs,
      :categories,
      &Offerings.filter_catalogue_categories_by_id/1
    )
    |> validate_required(@fields ++ @foreign_fields)
  end
end
