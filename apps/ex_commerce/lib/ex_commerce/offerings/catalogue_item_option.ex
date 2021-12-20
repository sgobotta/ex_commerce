defmodule ExCommerce.Offerings.CatalogueItemOption do
  @moduledoc """
  The CatalogueItemOption schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  import Decimal

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemVariant
  }

  @fields [:price_modifier, :is_visible]
  @foreign_fields [:brand_id, :catalogue_item_id, :catalogue_item_variant_id]
  @virtual_fields [:delete, :price_preview]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_options" do
    field :is_visible, :boolean, default: false
    field :price_modifier, :decimal
    field :brand_id, :binary_id

    # Virtual fields
    field :price_preview, :decimal, virtual: true
    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    # Associations
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
    |> cast(attrs, @fields ++ @foreign_fields ++ @virtual_fields)
    # Removed to put structs in form params
    # |> cast_assoc(:catalogue_item)
    # |> cast_assoc(:catalogue_item_variant)
    |> validate_required(@fields ++ @foreign_fields)
    |> validate_number(:price_modifier, greater_than_or_equal_to: 0)
    |> maybe_mark_for_deletion()
    |> maybe_build_price_preview(attrs)
  end

  defp maybe_mark_for_deletion(%{data: %{id: nil}} = changeset), do: changeset

  defp maybe_mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end

  defp preload_assocs(catalogue_item_option) do
    ExCommerce.Repo.preload(catalogue_item_option, [:catalogue_item_variant])
  end

  defp maybe_build_price_preview(
         %Ecto.Changeset{changes: %{price_modifier: price_modifier}} =
           changeset,
         %{"catalogue_item_variant" => %CatalogueItemVariant{price: price}}
       )
       when is_decimal(price_modifier) do
    put_change(changeset, :price_preview, apply_discount(price, price_modifier))
  end

  defp maybe_build_price_preview(
         %Ecto.Changeset{
           data:
             %__MODULE__{
               price_modifier: price_modifier
             } = catalogue_item_option
         } = changeset,
         _attrs
       ) do
    case preload_assocs(catalogue_item_option) do
      %__MODULE__{
        catalogue_item_variant: %CatalogueItemVariant{price: price}
      } ->
        put_change(
          changeset,
          :price_preview,
          apply_discount(price, price_modifier)
        )

      %__MODULE__{catalogue_item_variant: _catalogue_item_variant} ->
        changeset
    end
  end

  defp maybe_build_price_preview(changeset, _attrs), do: changeset

  defp apply_discount(price, price_modifier) do
    Decimal.round(
      Decimal.sub(price, Decimal.mult(price, Decimal.div(price_modifier, 100))),
      2
    )
  end
end
