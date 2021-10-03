defmodule ExCommerce.Offerings.CatalogueItem do
  @moduledoc """
  The CatalogueCategory schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @fields [:code, :name, :description]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_items" do
    field :code, :string
    field :description, :string
    field :name, :string
    field :brand_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(catalogue_item, attrs) do
    catalogue_item
    |> cast(attrs, @fields ++ @foreign_fields)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
