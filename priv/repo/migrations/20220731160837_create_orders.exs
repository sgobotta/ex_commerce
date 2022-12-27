defmodule ExCommerce.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :brand_id, :binary_id
      add :brand_name, :string

      add :shop_id, :binary_id
      add :shop_name, :string

      add :catalogue_id, :binary_id
      add :catalogue_name, :string

      add :buyer_name, :string
      add :address, :string
      add :note, :string

      add :price, :decimal

      add :status, :string

      add :order_items, {:array, :map}, null: false, default: []

      timestamps()
    end

    create index(:orders, [:brand_id])
    create index(:orders, [:shop_id])
    create index(:orders, [:catalogue_id])
  end
end
