defmodule ExCommerce.Repo.Migrations.CreateCatalogueItemOptions do
  use Ecto.Migration

  def change do
    create table(:catalogue_item_options, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :price_modifier, :decimal
      add :is_visible, :boolean, default: false, null: false
      add :brand_id, references(:brands, on_delete: :nothing, type: :binary_id)
      add :catalogue_item_id, references(:catalogue_items, on_delete: :nothing, type: :binary_id)

      add :catalogue_item_variant_id,
          references(:catalogue_item_variants, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogue_item_options, [:brand_id])
    create index(:catalogue_item_options, [:catalogue_item_id])
    create index(:catalogue_item_options, [:catalogue_item_variant_id])
  end
end
