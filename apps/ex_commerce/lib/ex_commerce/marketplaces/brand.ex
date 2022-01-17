defmodule ExCommerce.Marketplaces.Brand do
  @moduledoc """
  The Brand schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.{Accounts, Marketplaces, Offerings, Uploads}

  @fields [:name, :slug]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "brands" do
    field :name, :string
    field :slug, :string

    many_to_many :users,
                 Accounts.User,
                 join_through: Marketplaces.BrandUser

    has_many :shops, Marketplaces.Shop

    has_many :catalogues, Offerings.Catalogue
    has_many :catalogue_categories, Offerings.CatalogueCategory
    has_many :catalogue_items, Offerings.CatalogueItem
    has_many :catalogue_item_option_groups, Offerings.CatalogueItemOptionGroup
    has_many :photos, Uploads.Photo

    timestamps()
  end

  @doc false
  def changeset(brand, attrs) do
    brand
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> format_slug()
    |> unique_constraint(:slug)
  end

  defp format_slug(%Ecto.Changeset{changes: %{slug: _}} = changeset) do
    changeset
    |> update_change(:slug, fn slug ->
      slug
      |> String.downcase()
      |> String.replace(" ", "-")
    end)
  end

  defp format_slug(changeset), do: changeset
end
