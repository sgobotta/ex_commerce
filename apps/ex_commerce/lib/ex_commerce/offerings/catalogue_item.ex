defmodule ExCommerce.Offerings.CatalogueItem do
  use Ecto.Schema
  import Ecto.Changeset

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
    |> cast(attrs, [:code, :name, :description])
    |> validate_required([:code, :name, :description])
  end
end
