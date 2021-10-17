defmodule ExCommerce.Offerings.CatalogueItemVariant do
  @moduledoc """
  The CatalogueItemVariant schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:type, :price]
  @foreign_fields [:catalogue_item_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_variants" do
    field :price, :decimal
    field :type, :string

    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    belongs_to :catalogue_item,
               ExCommerce.Offerings.CatalogueItem,
               type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_variant, attrs) do
    catalogue_item_variant
    |> Map.put(:temp_id, catalogue_item_variant.temp_id || attrs["temp_id"])
    |> cast(attrs, @fields ++ @foreign_fields ++ [:delete])
    |> validate_required(@fields)
    |> maybe_mark_for_deletion()
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
