defmodule ExCommerce.Offerings.Catalogue do
  @moduledoc """
  The Catalogue schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  @fields [:name, :code]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogues" do
    field :name, :string
    field :code, :string
    field :brand_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(catalogue, attrs) do
    catalogue
    |> cast(attrs, @fields ++ @foreign_fields)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
