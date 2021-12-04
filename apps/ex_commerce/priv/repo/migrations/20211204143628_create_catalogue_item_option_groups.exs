defmodule ExCommerce.Repo.Migrations.CreateCatalogueItemOptionGroups do
  use Ecto.Migration

  def change do
    create table(:catalogue_item_option_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :mandatory, :boolean, default: false, null: false
      add :multiple_selection, :boolean, default: false, null: false
      add :max_selection, :integer
      add :brand_id, references(:brands, on_delete: :nothing, type: :binary_id)
      add :options, references(:catalogue_item_options, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogue_item_option_groups, [:brand_id])
    create index(:catalogue_item_option_groups, [:options])
  end
end
