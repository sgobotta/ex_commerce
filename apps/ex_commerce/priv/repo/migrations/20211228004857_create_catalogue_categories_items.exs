defmodule ExCommerce.Repo.Migrations.CreateCatalogueCategoriesItems do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:catalogue_categories_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visible, :boolean, default: false, null: false

      add :catalogue_category_id,
          references(:catalogue_categories,
            on_delete: :nothing,
            type: :binary_id
          )

      add :catalogue_item_id,
          references(:catalogue_items, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogue_categories_items, [:catalogue_category_id])
    create index(:catalogue_categories_items, [:catalogue_item_id])
  end
end
