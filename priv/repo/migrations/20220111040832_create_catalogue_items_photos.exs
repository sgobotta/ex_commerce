defmodule ExCommerce.Repo.Migrations.CreateCatalogueItemsPhotos do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:catalogue_items_photos, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :catalogue_item_id,
          references(:catalogue_items, on_delete: :nothing, type: :binary_id)

      add :photo_id, references(:photos, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogue_items_photos, [:catalogue_item_id])
    create index(:catalogue_items_photos, [:photo_id])
  end
end
