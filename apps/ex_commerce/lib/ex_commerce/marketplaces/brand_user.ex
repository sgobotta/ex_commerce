defmodule ExCommerce.Marketplaces.BrandUser do
  @moduledoc """
  The Brand User relationship schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:is_owner]
  @foreign_fields [:user_id, :brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "brands_users" do
    field :is_owner, :boolean, default: false

    belongs_to :user, ExCommerce.Accounts.User
    belongs_to :brand, ExCommerce.Marketplaces.Brand

    timestamps()
  end

  @doc false
  def changeset(brand_user, attrs) do
    brand_user
    |> cast(attrs, @fields ++ @foreign_fields)
    |> validate_required(@fields)
  end
end
