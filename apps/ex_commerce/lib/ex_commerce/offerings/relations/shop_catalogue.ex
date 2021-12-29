defmodule ExCommerce.Offerings.Relations.ShopCatalogue do
  @moduledoc """
  The ShopCatalogue relation schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.{Marketplaces, Offerings}

  @fields [:visible]
  @foreign_fields [:catalogue_id, :shop_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shops_catalogues" do
    field :visible, :boolean, default: false

    belongs_to :catalogue, Offerings.Catalogue
    belongs_to :shop, Marketplaces.Shop

    timestamps()
  end

  @doc false
  def changeset(shop_catalogue, attrs) do
    shop_catalogue
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:catalogue)
    |> cast_assoc(:shop)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
