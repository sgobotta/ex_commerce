defmodule ExCommerce.Uploads.Relations.ShopAvatar do
  @moduledoc """
  The ShopAvatar relationship schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_fields [:shop_id, :photo_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shops_avatars" do
    belongs_to :shop, ExCommerce.Marketplaces.Shop
    belongs_to :photo, ExCommerce.Uploads.Photo

    timestamps()
  end

  @doc false
  def changeset(shop_photo, attrs) do
    shop_photo
    |> cast(attrs, @foreign_fields)
    |> cast_assoc(:shop)
    |> cast_assoc(:photo)
    |> validate_required(@foreign_fields)
  end
end
