defmodule ExCommerce.Repo.Migrations.CreateCatalogueItemVariants do
  use Ecto.Migration

  def change do
    create table(:catalogue_item_variants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :price, :decimal

      add :catalogue_item_id,
          references(:catalogue_items, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:catalogue_item_variants, [:catalogue_item_id])
  end
end
