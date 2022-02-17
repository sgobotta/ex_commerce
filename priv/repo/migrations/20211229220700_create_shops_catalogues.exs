defmodule ExCommerce.Repo.Migrations.CreateShopsCatalogues do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:shops_catalogues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :visible, :boolean, default: false, null: false

      add :catalogue_id,
          references(:catalogues, on_delete: :nothing, type: :binary_id)

      add :shop_id, references(:shops, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:shops_catalogues, [:catalogue_id])
    create index(:shops_catalogues, [:shop_id])
  end
end
