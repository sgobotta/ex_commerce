defmodule ExCommerce.Repo.Migrations.CreateCatalogueItems do
  use Ecto.Migration

  def change do
    create table(:catalogue_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :code, :string
      add :name, :string
      add :description, :string
      add :brand_id, references(:brands, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogue_items, [:brand_id])
  end
end
