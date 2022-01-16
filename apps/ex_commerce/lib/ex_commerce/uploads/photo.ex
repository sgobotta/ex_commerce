defmodule ExCommerce.Uploads.Photo do
  @moduledoc """
  The Brand schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  @fields [:local_path, :full_local_path, :state, :uuid, :meta, :type]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "photos" do
    field :full_local_path, :string
    field :local_path, :string
    field :meta, :map, default: %{}
    field :state, Ecto.Enum, values: [:local, :uploaded, :delete]
    field :type, Ecto.Enum, values: [:avatar, :banner]
    field :uuid, :binary

    belongs_to :brand, ExCommerce.Marketplaces.Brand, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
