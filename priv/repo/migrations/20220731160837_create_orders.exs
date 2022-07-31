defmodule ExCommerce.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :brand_id, references(:brands, on_delete: :nothing, type: :binary_id)
      add :shop_id, references(:shops, on_delete: :nothing, type: :binary_id)

      add :catalogue_id,
          references(:catalogues, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:orders, [:brand_id])
    create index(:orders, [:shop_id])
    create index(:orders, [:catalogue_id])
  end
end
