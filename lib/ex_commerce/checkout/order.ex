defmodule ExCommerce.Checkout.Order do
  @moduledoc """
  The Order schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ExCommerce.Checkout.OrderItem

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :brand_id, :binary_id
    field :shop_id, :binary_id
    field :catalogue_id, :binary_id

    field :buyer_name, :string
    field :address, :string
    field :note, :string

    has_many :order_items, OrderItem, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :brand_id,
      :shop_id,
      :catalogue_id,
      :buyer_name,
      :address,
      :note
    ])
    |> validate_required([
      :brand_id,
      :shop_id,
      :catalogue_id,
      :buyer_name,
      :address,
      :note
    ])
  end

  # def changeset_pre_order(order, attrs) do
  #   order
  #   |> cast(attrs, [:brand_id, :shop_id, :catalogue_id, :order_items])
  #   |> validate_required([
  #     :brand_id,
  #     :shop_id,
  #     :catalogue_id,
  #     :order_items
  #   ])
  # end
end
