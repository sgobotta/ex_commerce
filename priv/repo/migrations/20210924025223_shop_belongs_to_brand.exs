defmodule ExCommerce.Repo.Migrations.ShopBelongsToBrand do
  @moduledoc false

  use Ecto.Migration

  def change do
    alter table(:shops) do
      add :brand_id, references(:brands, type: :binary_id)
    end
  end
end
