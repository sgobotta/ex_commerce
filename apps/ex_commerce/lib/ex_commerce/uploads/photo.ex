defmodule ExCommerce.Uploads.Photo do
  @moduledoc """
  The Brand schema
  """
  use Ecto.Schema

  alias ExCommerce.Uploads.Photo

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

  @doc """
  Returns the remote path.
  """
  def get_remote_path(%Photo{meta: meta, local_path: local_path}) do
    Map.get(meta, "secure_url", local_path)
  end
end
