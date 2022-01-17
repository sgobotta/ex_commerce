defmodule ExCommerce.Repo.Migrations.CreateShopsAvatars do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:shops_avatars, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :shop_id,
          references(:shops, on_delete: :nothing, type: :binary_id)

      add :photo_id, references(:photos, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:shops_avatars, [:shop_id])
    create index(:shops_avatars, [:photo_id])
  end
end
