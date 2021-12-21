defmodule ExCommerce.Repo.Migrations.CreateBrands do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:brands, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
