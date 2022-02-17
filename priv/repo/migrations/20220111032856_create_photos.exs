defmodule ExCommerce.Repo.Migrations.CreatePhotos do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:photos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :local_path, :string
      add :full_local_path, :string
      add :state, :string
      add :uuid, :binary
      add :meta, :map, null: false, default: %{}
      add :type, :string
      add :brand_id, references(:brands, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:photos, [:brand_id])
  end
end
