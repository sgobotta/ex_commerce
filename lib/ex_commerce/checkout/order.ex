defmodule ExCommerce.Checkout.Order do
  @moduledoc """
  The Order schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias ExCommerce.Checkout.OrderItem

  @type t :: %__MODULE__{}

  @details_fields [:address, :buyer_name, :note]
  @marketplace_fields [
    :brand_id,
    :brand_name,
    :shop_id,
    :shop_name,
    :catalogue_id,
    :catalogue_name
  ]

  @status [:pending, :in_progress, :completed]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :brand_id, :binary_id
    field :brand_name, :string

    field :shop_id, :binary_id
    field :shop_name, :string

    field :catalogue_id, :binary_id
    field :catalogue_name, :string

    field :buyer_name, :string
    field :address, :string
    field :note, :string

    field :price, :decimal

    field :status, Ecto.Enum, values: @status, default: :pending

    embeds_many :order_items, OrderItem

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(
      attrs,
      @details_fields ++
        @marketplace_fields ++
        [
          :price,
          :status
        ]
    )
    |> validate_required(
      @marketplace_fields ++
        [
          :address,
          :buyer_name,
          :price,
          :status
        ]
    )
  end
end

defmodule ExCommerce.Checkout.OrderItem do
  @moduledoc """
  The embedded OrderItem for the order shema
  """

  use Ecto.Schema

  embedded_schema do
    field :quantity, :integer
    field :prie, :decimal

    field :variant_id, :binary_id
    field :variant_name, :string

    field :catalogue_item_id, :binary_id
    field :catalogue_item_name, :string
  end
end
