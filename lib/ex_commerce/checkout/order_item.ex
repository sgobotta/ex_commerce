defmodule ExCommerce.Checkout.OrderItem do
  @moduledoc """
  The OrderItem schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "order_items" do
    field :quantity, :integer
    field :catalogue_item_id, :binary
    field :variant_id, :binary
    field :price, :decimal
    field :variants, {:array, :map}, virtual: true, default: []
    field :option_groups, :map, default: %{}
    field :available_option_groups, {:array, :map}, virtual: true, default: []

    timestamps()
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:quantity, :catalogue_item_id, :variant_id, :option_groups])
    |> validate_required([
      :quantity,
      :catalogue_item_id,
      :variant_id,
      :option_groups
    ])

    # |> validate_option_groups()
  end

  # defp validate_option_groups(changeset) do
  #   validate_change(changeset, :option_groups, fn :option_groups,
  #                                                 option_groups ->
  #     # IO.inspect(option_groups, label: "\n\nOption Groups!")
  #     []
  #   end)

  #   # changeset
  # end
end
