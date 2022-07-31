defmodule ExCommerce.Checkout.OrderItem do
  @moduledoc """
  The OrderItem schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "order_items" do
    field :quantity, :integer
    field :catalogue_item_id, :binary_id
    field :variant_id, :binary_id
    field :price, :decimal
    field :variants, {:array, :map}, virtual: true, default: []
    field :option_groups, :map, default: %{}
    field :available_option_groups, {:array, :map}, virtual: true, default: []

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [
      :catalogue_item_id,
      :option_groups,
      :price,
      :quantity,
      :variant_id
    ])
    |> validate_required([
      :catalogue_item_id,
      :option_groups,
      :price,
      :quantity,
      :variant_id
    ])
  end

  @doc """
  Given an #{__MODULE__} changeset, returns the total price, that includues the
  sum of the variant price and the total `option_groups` price.
  """
  @spec get_total_price(Ecto.Changeset.t()) :: Decimal.t()
  def get_total_price(
        %Ecto.Changeset{changes: changes, data: %__MODULE__{} = data} = cs
      ) do
    variant_price = get_variant_price(changes, data)
    option_groups_price = get_option_groups_price(cs)
    %{quantity: quantity} = changes

    ExCommerceNumeric.add(variant_price, option_groups_price)
    |> ExCommerceNumeric.mult(quantity)
    |> ExCommerceNumeric.format_price()
  end

  defp get_variant_price(changes, %__MODULE__{variants: variants}) do
    case Map.get(changes, :variant_id) do
      nil ->
        0

      variant_id ->
        %CatalogueItemVariant{price: price} =
          Enum.find(variants, fn %CatalogueItemVariant{id: id} ->
            id == variant_id
          end)

        price
    end
  end

  defp get_option_groups_price(%Ecto.Changeset{
         changes: %{option_groups: ogs},
         data: %__MODULE__{available_option_groups: aogs}
       }) do
    Enum.reduce(
      aogs.values,
      ExCommerceNumeric.format_price(0),
      fn %CatalogueItemOptionGroup{id: id} = og, acc ->
        get_total_option_group_price(
          Map.fetch!(ogs, id)["value"],
          og
        )
        |> ExCommerceNumeric.add(acc)
      end
    )
  end

  defp get_option_groups_price(%Ecto.Changeset{}),
    do: ExCommerceNumeric.format_price(0)

  defp get_total_option_group_price([], %CatalogueItemOptionGroup{}),
    do: ExCommerceNumeric.format_price(0)

  defp get_total_option_group_price(option_ids, %CatalogueItemOptionGroup{
         options: options
       })
       when is_list(option_ids) do
    Enum.reduce(
      options,
      ExCommerceNumeric.format_price(0),
      fn %CatalogueItemOption{
           id: id,
           catalogue_item_variant: %CatalogueItemVariant{price: price},
           price_modifier: price_modifier
         },
         acc ->
        case id in option_ids do
          true ->
            ExCommerceNumeric.add(
              acc,
              CatalogueItemOption.apply_discount(price, price_modifier)
            )

          false ->
            acc
        end
      end
    )
  end

  defp get_total_option_group_price(nil, %CatalogueItemOptionGroup{}),
    do: ExCommerceNumeric.format_price(0)

  defp get_total_option_group_price(option_id, %CatalogueItemOptionGroup{
         options: options
       })
       when is_binary(option_id) do
    %CatalogueItemOption{
      catalogue_item_variant: %CatalogueItemVariant{price: price},
      price_modifier: price_modifier
    } =
      Enum.find(options, 0, fn %CatalogueItemOption{id: id} ->
        option_id == id
      end)

    CatalogueItemOption.apply_discount(price, price_modifier)
  end
end
