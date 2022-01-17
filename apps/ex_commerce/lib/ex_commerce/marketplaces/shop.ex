defmodule ExCommerce.Marketplaces.Shop do
  @moduledoc """
  The Shop schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{Catalogue, Relations}
  alias ExCommerce.Uploads

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

    many_to_many :avatars, Uploads.Photo,
      join_through: Uploads.Relations.ShopAvatar,
      on_replace: :delete,
      on_delete: :delete_all

    many_to_many :banners, Uploads.Photo,
      join_through: Uploads.Relations.ShopBanner,
      on_replace: :delete,
      on_delete: :delete_all

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
    |> maybe_assoc_avatars(attrs)
    |> maybe_assoc_banners(attrs)
    |> validate_required(@fields ++ @foreign_fields)
    |> format_slug()
    |> unique_constraint(:slug)
  end

  defp maybe_assoc_avatars(changeset, %{"avatars" => avatars}),
    do: put_assoc(changeset, :avatars, avatars)

  defp maybe_assoc_avatars(changeset, _attrs), do: changeset

  defp maybe_assoc_banners(changeset, %{"banners" => banners}),
    do: put_assoc(changeset, :banners, banners)

  defp maybe_assoc_banners(changeset, _attrs), do: changeset

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
