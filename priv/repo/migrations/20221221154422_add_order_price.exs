defmodule ExCommerce.Repo.Migrations.AddOrderPrice do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :price, :decimal
    end
  end
end
