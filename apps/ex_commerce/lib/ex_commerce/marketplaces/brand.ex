defmodule ExCommerce.Marketplaces.Brand do
  @moduledoc """
  The Brand schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:name]

  # @foreign_fields [:user_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "brands" do
    field :name, :string

    many_to_many :users,
                 ExCommerce.Accounts.User,
                 join_through: ExCommerce.Marketplaces.BrandUser

    has_many :shops, ExCommerce.Marketplaces.Shop

    has_many :catalogues, ExCommerce.Offerings.Catalogue
    has_many :catalogue_categories, ExCommerce.Offerings.CatalogueCategory

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
