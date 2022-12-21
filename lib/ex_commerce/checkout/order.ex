defmodule ExCommerce.Checkout.Order do
  @moduledoc """
  The Order schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ExCommerce.Checkout.OrderItem

  @type t :: %__MODULE__{}

  @details_fields [:address, :buyer_name, :note]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :brand_id, :binary_id
    field :shop_id, :binary_id
    field :catalogue_id, :binary_id

    field :buyer_name, :string
    field :address, :string
    field :note, :string

    field :price, :decimal

    has_many :order_items, OrderItem, on_delete: :delete_all

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
end
