defmodule ExCommerce.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :catalogue_item_id, :binary
      add :variant_id, :binary
      add :quantity, :integer
      add :price, :decimal
      add :option_groups, {:array, :map}

      timestamps()
    end
  end
end
