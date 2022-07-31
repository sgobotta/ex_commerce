defmodule ExCommerce.Repo.Migrations.UpdateOrderItemBelongsToOrder do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:order_items) do
      add :order_id, references(:orders, type: :binary_id)
    end
  end
end
