defmodule ExCommerce.Marketplaces.Shop do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :name,
    :slug,
    :description,
    :telephone,
    :banner_message,
    :address
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shops" do
    field :name, :string
    field :slug, :string
    field :description, :string, size: 128
    field :telephone, :string
    field :banner_message, :string, size: 128
    field :address, :string

    timestamps()
  end

  @doc false
  def changeset(shop, attrs) do
    shop
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
