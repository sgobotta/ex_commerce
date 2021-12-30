defmodule ExCommerce.Marketplaces.Shop do
  @moduledoc """
  The Shop schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{Catalogue, Relations}

  @fields [
    :name,
    :slug,
    :description,
    :telephone,
    :banner_message,
    :address
  ]

  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shops" do
    field :name, :string
    field :slug, :string
    field :description, :string, size: 128
    field :telephone, :string
    field :banner_message, :string, size: 128
    field :address, :string

    belongs_to :brand,
               ExCommerce.Marketplaces.Brand,
               type: :binary_id

    many_to_many :catalogues, Catalogue,
      join_through: Relations.ShopCatalogue,
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(shop, attrs) do
    shop
    |> cast(attrs, @fields ++ @foreign_fields)
    |> validate_required(@fields ++ @foreign_fields)
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
