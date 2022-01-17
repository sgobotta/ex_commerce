defmodule ExCommerce.Repo.Migrations.CreateShops do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:shops, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string

      timestamps()
    end

    create unique_index(:shops, [:slug])
  end
end
