defmodule ExCommerce.Checkout.Cart.Order do
  @moduledoc """
  The Order schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ExCommerce.Checkout.Cart

  @type t :: %__MODULE__{}

  @details_fields [:address, :buyer_name, :note]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  embedded_schema do
    field :brand_id, :binary_id
    field :shop_id, :binary_id
    field :catalogue_id, :binary_id

    field :buyer_name, :string
    field :address, :string
    field :note, :string

    field :price, :decimal, default: Decimal.new(0)

    embeds_many :order_items, Cart.OrderItem

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(
      attrs,
      [
        :brand_id,
        :catalogue_id,
        :price,
        :shop_id
      ] ++ @details_fields
    )
    |> validate_required([
      :address,
      :brand_id,
      :buyer_name,
      :catalogue_id,
      :price,
      :shop_id
    ])
  end

  @doc false
  def change_details(order, attrs) do
    order
    |> cast(attrs, @details_fields)
    |> validate_required([:address, :buyer_name])
  end

  @doc """
  Given an #{Ecto.Changeset} struct, applies changes to return an updated
  #{__MODULE__}.
  """
  @spec apply(Ecto.Changeset.t()) :: t()
  def apply(%Ecto.Changeset{} = changeset) do
    apply_changes(changeset)
  end

  @doc """
  Given an #{Ecto.Changeset} struct, applies a new price to return an updated
  #{__MODULE__}.
  """
  @spec apply_price(t(), Decimal.t()) :: t()
  def apply_price(order, price) do
    attrs = %{price: price}

    order
    |> cast(attrs, [:price])
    |> validate_required([:price])
    |> apply()
  end

  @doc """
  Given a `#{__MODULE__}` struct returns a map that represents a cart order.
  This function is commonly used to convert `#{__MODULE__}` structs to maps that
  can be used for creating #{ExCommerce.Checkout.Order} changesets.
  """
  @spec marshal(t()) :: map()
  def marshal(%__MODULE__{order_items: cart_order_items} = cart_order) do
    cart_order_items =
      Enum.map(cart_order_items, fn %Cart.OrderItem{} = coi ->
        Cart.OrderItem.marshal(coi)
      end)

    Map.from_struct(cart_order)
    |> Map.take([
      :address,
      :brand_id,
      :buyer_name,
      :catalogue_id,
      :note,
      :price,
      :shop_id
    ])
    |> Map.put(:order_items, cart_order_items)
  end

  @doc """
  Given an `#{__MODULE__}` returns the calculated price of it's order items.
  """
  @spec calculate_price(t()) :: Decimal.t()
  def calculate_price(%__MODULE__{order_items: []}), do: Decimal.new(0)

  def calculate_price(%__MODULE__{order_items: order_items}) do
    order_items
    |> Enum.reduce(0, fn %Cart.OrderItem{price: price}, acc ->
      ExCommerceNumeric.add(acc, price)
    end)
  end
end
