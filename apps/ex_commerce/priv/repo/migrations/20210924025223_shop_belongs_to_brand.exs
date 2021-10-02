defmodule ExCommerce.Repo.Migrations.ShopBelongsToBrand do
  use Ecto.Migration

  def change do
    alter table(:shops) do
      add :brand_id, references(:brands, type: :binary_id)
    end
  end
end
