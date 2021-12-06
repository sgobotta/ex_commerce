defmodule ExCommerce.Offerings.CatalogueItemOption do
  @moduledoc """
  The CatalogueItemOption schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemVariant
  }

  @fields [:price_modifier, :is_visible]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_options" do
    field :is_visible, :boolean, default: false
    field :price_modifier, :decimal
    field :brand_id, :binary_id

    # Virtual fields
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    belongs_to :catalogue_item, CatalogueItem, type: :binary_id
    belongs_to :catalogue_item_variant, CatalogueItemVariant, type: :binary_id

    belongs_to :catalogue_item_option_group,
               ExCommerce.Offerings.CatalogueItemOptionGroup,
               type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_option, attrs) do
    catalogue_item_option
    |> Map.put(
      :temp_id,
      catalogue_item_option.temp_id || attrs["temp_id"]
    )
    |> cast(attrs, @fields ++ @foreign_fields)
    |> cast_assoc(:catalogue_item)
    |> cast_assoc(:catalogue_item_variant)
    |> validate_required(@fields ++ @foreign_fields)
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
