defmodule ExCommerce.Repo.Migrations.UpdateShopPhotosField do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:shops) do
      add :avatars, {:array, :map}, null: false, default: []
      add :banners, {:array, :map}, null: false, default: []
    end
  end
end
