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

    field :catalogue_code, :string
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
    |> cast_embed(:order_items, required: true)
    |> validate_change(:order_items, &validator/2)
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

  @doc """
  Given an #{Ecto.Changeset} struct, applies changes to return an updated
  #{__MODULE__}.
  """
  @spec apply(Ecto.Changeset.t()) :: t()
  def apply(%Ecto.Changeset{} = changeset) do
    apply_changes(changeset)
  end

  defp validator(:order_items, []), do: [order_items: "Cannot be empty"]
  defp validator(:order_items, value) when is_list(value), do: []

  defp validator(:order_items, _value),
    do: [order_items: "Must be a list of #{OrderItem}"]
end

defmodule ExCommerce.Checkout.OrderItem do
  @moduledoc """
  The embedded OrderItem for the order shema
  """
  alias ExCommerce.Checkout.OrderItemOptionGroup

  use Ecto.Schema

  import Ecto.Changeset

  @fields [
    :quantity,
    :price,
    :catalogue_item_code,
    :catalogue_item_description,
    :catalogue_item_id,
    :catalogue_item_name,
    :variant_code,
    :variant_id,
    :variant_name
  ]

  embedded_schema do
    field :quantity, :integer
    field :price, :decimal

    field :variant_code, :string
    field :variant_id, :binary_id
    field :variant_name, :string

    field :catalogue_item_code, :string
    field :catalogue_item_description, :string
    field :catalogue_item_id, :binary_id
    field :catalogue_item_name, :string

    embeds_many :option_groups, OrderItemOptionGroup
  end

  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end

defmodule ExCommerce.Checkout.OrderItemOptionGroup do
  @moduledoc """
  The embedded OrderItemOptionGroup for the OrderItem embedded shema.
  """
  use Ecto.Schema

  alias ExCommerce.Checkout.OrderItemOption

  embedded_schema do
    field :catalogue_item_option_group_id, :binary_id
    field :catalogue_item_option_group_name, :string

    embeds_many :options, OrderItemOption
  end
end

defmodule ExCommerce.Checkout.OrderItemOption do
  @moduledoc """
  The embedded OrderitemOption for the OrderItemOptionGroup embedded schema.
  """
  use Ecto.Schema

  embedded_schema do
    field :catalogue_item_id, :binary_id
    field :catalogue_item_name, :string

    field :catalogue_item_variant_id, :binary_id
    field :catalogue_item_variant_name, :string

    field :price, :decimal
  end
end
