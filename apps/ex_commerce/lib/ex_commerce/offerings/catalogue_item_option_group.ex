defmodule ExCommerce.Offerings.CatalogueItemOptionGroup do
  @moduledoc """
  The CatalogueItemOptionGroup schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.{
    CatalogueItem,
    CatalogueItemOption
  }

  alias ExCommerce.Offerings.Relations.CatalogueItemOptionGroupItem

  @fields [:mandatory, :max_selection, :multiple_selection, :name, :description]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_option_groups" do
    field :brand_id, :binary_id
    field :mandatory, :boolean, default: false
    field :max_selection, :integer
    field :multiple_selection, :boolean, default: false
    field :name, :string
    field :description, :string

    field :temp_id, :string, virtual: true
    field :delete, :boolean, virtual: true

    has_many :options, CatalogueItemOption, on_delete: :delete_all

    many_to_many :items, CatalogueItem,
      join_through: CatalogueItemOptionGroupItem,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_option_group, attrs) do
    catalogue_item_option_group
    |> Map.put(
      :temp_id,
      catalogue_item_option_group.temp_id || attrs["temp_id"]
    )
    |> cast(attrs, @fields ++ @foreign_fields ++ [:delete])
    |> cast_assoc(:options)
    |> cast_assoc(:items)
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
