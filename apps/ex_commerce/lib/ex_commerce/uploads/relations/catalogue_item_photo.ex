defmodule ExCommerce.Uploads.Relations.CatalogueItemPhoto do
  @moduledoc """
  The CatalogueItemPhoto relationship schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @foreign_fields [:catalogue_item_id, :photo_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_items_photos" do
    belongs_to :catalogue_item, ExCommerce.Offerings.CatalogueItem
    belongs_to :photo, ExCommerce.Uploads.Photo, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_photo, attrs) do
    catalogue_item_photo
    |> cast(attrs, @foreign_fields)
    |> cast_assoc(:catalogue_item)
    |> cast_assoc(:photo)
    |> validate_required(@foreign_fields)
  end
end
