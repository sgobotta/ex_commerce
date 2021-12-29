defmodule ExCommerce.Repo.Migrations.UpdateCodeFields do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:catalogues) do
      add :code, :string, null: false
    end

    alter table(:catalogue_item_variants) do
      add :code, :string, null: false
    end

    alter table(:catalogue_item_option_groups) do
      add :code, :string, null: false
    end
  end
end
