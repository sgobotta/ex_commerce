defmodule ExCommerce.Repo.Migrations.UpdateBrandSlug do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:brands) do
      add :slug, :string, null: false
    end

    create unique_index(:brands, [:slug])
  end
end
