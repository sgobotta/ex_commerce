defmodule ExCommerce.Repo.Migrations.UpdateBasicShopFields do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:shops) do
      add :description, :string, size: 128, null: false
      add :telephone, :string, null: false
      add :banner_message, :string, size: 128, null: false
      add :address, :string, null: false
    end
  end
end
