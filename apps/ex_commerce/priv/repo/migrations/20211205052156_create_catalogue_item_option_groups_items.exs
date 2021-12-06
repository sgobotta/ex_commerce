defmodule ExCommerce.Repo.Migrations.CreateCatalogueItemOptionGroupsItems do
  use Ecto.Migration

  def change do
    create table(:catalogue_item_option_groups_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visible, :boolean, default: false, null: false

      add :catalogue_item_option_group_id,
          references(:catalogue_item_option_groups, on_delete: :nothing, type: :binary_id)

      add :catalogue_item_id, references(:catalogue_items, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogue_item_option_groups_items, [:catalogue_item_option_group_id])
    create index(:catalogue_item_option_groups_items, [:catalogue_item_id])
  end
end
