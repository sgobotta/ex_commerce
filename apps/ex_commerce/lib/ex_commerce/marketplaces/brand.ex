defmodule ExCommerce.Marketplaces.Brand do
  @moduledoc """
  The Brand schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.{Accounts, Marketplaces, Offerings}

  @fields [:name]

  # @foreign_fields [:user_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "brands" do
    field :name, :string

    many_to_many :users,
                 Accounts.User,
                 join_through: Marketplaces.BrandUser

    has_many :shops, Marketplaces.Shop

    has_many :catalogues, Offerings.Catalogue
    has_many :catalogue_categories, Offerings.CatalogueCategory
    has_many :catalogue_items, Offerings.CatalogueItem

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
