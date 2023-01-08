defmodule ExCommerce.Checkout.Cart.OrderItem do
  @moduledoc """
  The OrderItem schema
  """
  use Ecto.Schema

  import Ecto.Changeset
  import ExCommerceNumeric

  alias ExCommerceWeb.CheckoutLive.CatalogueItem

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption,
    CatalogueItemOptionGroup,
    CatalogueItemVariant
  }

  alias ExCommerce.Checkout.Cart

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  embedded_schema do
    field :quantity, :integer
    field :price, :decimal
    field :variants, {:array, :map}, virtual: true, default: []
    field :option_groups, :map, default: %{}
    field :temp_id, :string, virtual: true

    field :available_option_groups, :map,
      virtual: true,
      default: %{values: [], rules: []}

    belongs_to :catalogue_item, CatalogueItem, type: :binary_id
    belongs_to :variant, CatalogueItemVariant, type: :binary_id
    belongs_to :order, Cart.Order, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [
      :catalogue_item_id,
      :option_groups,
      :order_id,
      :price,
      :quantity,
      :variant_id
    ])
    |> validate_required([
      :catalogue_item_id,
      :option_groups,
      :quantity,
      :variant_id
    ])
  end

  @doc """
  Given a `#{__MODULE__}` struct returns a map that represents a cart order
  item.
  This function is commonly used to convert `#{__MODULE__}` structs to maps that
  can be used for creating #{ExCommerce.Checkout.OrderItem} changesets.
  """
  @spec marshal(t()) :: map()
  def marshal(%__MODULE__{} = cart_order_item) do
    option_groups = marshal_option_groups(cart_order_item)

    %__MODULE__{
      catalogue_item: %CatalogueItem{
        code: catalogue_item_code,
        description: catalogue_item_description,
        id: catalogue_item_id,
        name: catalogue_item_name
      },
      variant: %CatalogueItemVariant{
        code: variant_code,
        id: variant_id,
        type: variant_name
      }
    } = cart_order_item

    Map.from_struct(cart_order_item)
    |> Map.take([:price, :quantity])
    |> Map.put(:variant_code, variant_code)
    |> Map.put(:variant_id, variant_id)
    |> Map.put(:variant_name, variant_name)
    |> Map.put(:catalogue_item_code, catalogue_item_code)
    |> Map.put(:catalogue_item_description, catalogue_item_description)
    |> Map.put(:catalogue_item_id, catalogue_item_id)
    |> Map.put(:catalogue_item_name, catalogue_item_name)
    |> Map.put(:option_groups, option_groups)
  end

  @spec marshal_option_groups(t()) :: [map()]
  defp marshal_option_groups(%__MODULE__{
         available_option_groups: %{values: available_option_groups},
         option_groups: option_groups
       }) do
    Enum.reduce(option_groups, [], fn option_group, acc ->
      case marshal_option_group(option_group, available_option_groups) do
        nil ->
          acc

        option_group ->
          acc ++ [option_group]
      end
    end)
  end

  @spec marshal_option_group({Ecto.UUID.t(), map()}, [
          CatalogueItemOptionGroup.t()
        ]) :: map() | nil
  defp marshal_option_group(
         {_catalogue_option_group_id, %{"value" => []}},
         _available_option_groups
       ),
       do: nil

  defp marshal_option_group(
         {_catalogue_option_group_id, %{"value" => ""}},
         _available_option_groups
       ),
       do: nil

  defp marshal_option_group(
         {catalogue_option_group_id, %{"value" => values}},
         available_option_groups
       )
       when is_list(values) do
    %CatalogueItemOptionGroup{
      code: code,
      id: id,
      name: name,
      options: options
    } = find_group(available_option_groups, catalogue_option_group_id)

    catalogue_item_options =
      Enum.filter(options, fn %CatalogueItemOption{id: id} ->
        id in values
      end)

    options = parse_catalogue_item_options(catalogue_item_options)

    %{
      catalogue_item_option_group_code: code,
      catalogue_item_option_group_id: id,
      catalogue_item_option_group_name: name,
      options: options
    }
  end

  defp marshal_option_group(
         {catalogue_option_group_id, %{"value" => value}},
         available_option_groups
       )
       when is_binary(value) do
    %CatalogueItemOptionGroup{
      code: code,
      id: id,
      name: name,
      options: options
    } = find_group(available_option_groups, catalogue_option_group_id)

    %CatalogueItemOption{} =
      catalogue_item_option =
      Enum.find(options, fn %CatalogueItemOption{id: id} ->
        id == value
      end)

    options = parse_catalogue_item_options([catalogue_item_option])

    %{
      catalogue_item_option_group_code: code,
      catalogue_item_option_group_id: id,
      catalogue_item_option_group_name: name,
      options: options
    }
  end

  @spec find_group([CatalogueItemOptionGroup.t()], Ecto.UUID.t()) ::
          CatalogueItemOptionGroup.t()
  defp find_group(available_option_groups, option_group_id) do
    Enum.find(available_option_groups, fn %CatalogueItemOptionGroup{
                                            id: id
                                          } ->
      id == option_group_id
    end)
  end

  @spec parse_catalogue_item_options([CatalogueItemOption.t()]) :: [map()]
  defp parse_catalogue_item_options(options) do
    Enum.map(options, fn %CatalogueItemOption{} = cio ->
      parse_catalogue_item_option(cio)
    end)
  end

  @spec parse_catalogue_item_option(CatalogueItemOption.t()) :: map()
  defp parse_catalogue_item_option(%CatalogueItemOption{
         catalogue_item_variant: %CatalogueItemVariant{
           catalogue_item: %CatalogueItem{
             code: catalogue_item_code,
             description: catalogue_item_description,
             id: catalogue_item_id,
             name: catalogue_item_name
           },
           code: catalogue_item_variant_code,
           id: catalogue_item_variant_id,
           price: variant_price,
           type: catalogue_item_variant_name
         },
         price_modifier: %Decimal{coef: 0}
       }) do
    %{
      catalogue_item_code: catalogue_item_code,
      catalogue_item_description: catalogue_item_description,
      catalogue_item_id: catalogue_item_id,
      catalogue_item_name: catalogue_item_name,
      catalogue_item_variant_code: catalogue_item_variant_code,
      catalogue_item_variant_id: catalogue_item_variant_id,
      catalogue_item_variant_name: catalogue_item_variant_name,
      price: format_price(variant_price)
    }
  end

  defp parse_catalogue_item_option(
         %CatalogueItemOption{
           catalogue_item_variant: %CatalogueItemVariant{
             catalogue_item: %CatalogueItem{
               code: catalogue_item_code,
               description: catalogue_item_description,
               id: catalogue_item_id,
               name: catalogue_item_name
             },
             code: catalogue_item_variant_code,
             id: catalogue_item_variant_id,
             price: variant_price,
             type: catalogue_item_variant_name
           },
           price_modifier: %Decimal{}
         } = cio
       ) do
    discount_price =
      CatalogueItemOption.get_discount_price(cio)
      |> format_price()

    %{
      catalogue_item_code: catalogue_item_code,
      catalogue_item_description: catalogue_item_description,
      catalogue_item_id: catalogue_item_id,
      catalogue_item_name: catalogue_item_name,
      catalogue_item_variant_code: catalogue_item_variant_code,
      catalogue_item_variant_id: catalogue_item_variant_id,
      catalogue_item_variant_name: catalogue_item_variant_name,
      discount_price: discount_price,
      price: format_price(variant_price)
    }
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
