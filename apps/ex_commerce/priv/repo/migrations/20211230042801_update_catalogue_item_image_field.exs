defmodule ExCommerce.Repo.Migrations.UpdateCatalogueItemImageField do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:catalogue_items) do
      add :photos, {:array, :map}, null: false, default: []
    end
  end
end
