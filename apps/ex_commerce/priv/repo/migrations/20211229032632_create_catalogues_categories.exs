defmodule ExCommerce.Repo.Migrations.CreateCataloguesCategories do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:catalogues_categories, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visible, :boolean, default: false, null: false

      add :catalogue_category_id,
          references(:catalogue_categories,
            on_delete: :nothing,
            type: :binary_id
          )

      add :catalogue_id,
          references(:catalogues, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogues_categories, [:catalogue_category_id])
    create index(:catalogues_categories, [:catalogue_id])
  end
end
