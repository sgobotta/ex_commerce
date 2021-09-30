defmodule ExCommerce.Repo.Migrations.CreateBrandsUsers do
  use Ecto.Migration

  def change do
    create table(:brands_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_owner, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :brand_id, references(:brands, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:brands_users, [:user_id])
    create index(:brands_users, [:brand_id])
  end
end
