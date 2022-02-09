defmodule ExCommerce.Offerings.Relations.CatalogueCategory do
  @moduledoc """
  The Catalogue / CatalogueCategory
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{Catalogue, CatalogueCategory}

  @fields [:visible]
  @foreign_fields [:catalogue_id, :catalogue_category_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogues_categories" do
    field :visible, :boolean, default: false

    belongs_to :catalogue, Catalogue
    belongs_to :catalogue_category, CatalogueCategory

    timestamps()
  end

  @doc false
  def changeset(catalogue_category, attrs) do
    catalogue_category
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:catalogue)
    |> cast_assoc(:catalogue_category)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
