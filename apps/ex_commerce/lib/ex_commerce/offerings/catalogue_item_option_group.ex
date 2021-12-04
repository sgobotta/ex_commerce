defmodule ExCommerce.Offerings.CatalogueItemOptionGroup do
  @moduledoc """
  The CatalogueItemOptionGroup schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias ExCommerce.Offerings.CatalogueItemOption

  @fields [:mandatory, :max_selection, :multiple_selection]
  @foreign_fields [:brand_id]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "catalogue_item_option_groups" do
    field :mandatory, :boolean, default: false
    field :max_selection, :integer
    field :multiple_selection, :boolean, default: false
    field :brand_id, :binary_id

    has_many :options, CatalogueItemOption

    timestamps()
  end

  @doc false
  def changeset(catalogue_item_option_group, attrs) do
    catalogue_item_option_group
    |> cast(attrs, @fields ++ @foreign_fields)
    |> validate_required(@fields ++ @foreign_fields)
  end
end
