defmodule ExCommerce.Marketplaces.Shop do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shops" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(shop, attrs) do
    shop
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end
