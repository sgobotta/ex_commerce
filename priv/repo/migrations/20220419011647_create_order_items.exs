defmodule ExCommerce.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :catalogue_item_id,
          references(:catalogue_items, on_delete: :nothing, type: :binary_id)

      add :variant_id,
          references(:catalogue_item_variants,
            on_delete: :nothing,
            type: :binary_id
          )

      add :quantity, :integer
      add :price, :decimal
      add :option_groups, :map

      timestamps()
    end

    create index(:order_items, [:catalogue_item_id])
    create index(:order_items, [:variant_id])
  end
end
