defmodule ExCommerce.Repo.Migrations.UpdateCatalogueItemGroupNameDescFields do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:catalogue_item_option_groups) do
      add :name, :string, null: false
      add :description, :string, null: false
    end
  end
end
