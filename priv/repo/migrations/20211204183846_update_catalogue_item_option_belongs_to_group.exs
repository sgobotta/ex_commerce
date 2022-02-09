defmodule ExCommerce.Repo.Migrations.UpdateCatalogueItemOptionBelongsToGroup do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:catalogue_item_options) do
      add :catalogue_item_option_group_id,
          references(:catalogue_item_option_groups, type: :binary_id)
    end
  end
end
