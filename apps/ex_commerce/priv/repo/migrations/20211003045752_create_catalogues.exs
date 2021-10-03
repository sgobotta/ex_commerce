defmodule ExCommerce.Repo.Migrations.CreateCatalogues do
  use Ecto.Migration

  def change do
    create table(:catalogues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :brand_id, references(:brands, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:catalogues, [:brand_id])
  end
end
