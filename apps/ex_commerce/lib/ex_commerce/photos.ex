defmodule ExCommerce.Photos do
  @moduledoc """
  The Photos context.
  """

  @doc """
  Returns a map representing a new photo.
  """
  @spec create_photo(map) :: map
  def create_photo(%{
        local_path: local_path,
        full_local_path: full_local_path,
        uuid: uuid,
        brand_id: brand_id
      }) do
    %{
      "local_path" => local_path,
      "full_local_path" => full_local_path,
      "is_remote" => false,
      "delete" => false,
      "uuid" => uuid,
      "brand_id" => brand_id,
      "meta" => %{}
    }
  end

  @doc """
  Given a photo returns it's local path.
  """
  def get_local_path(photo), do: Map.get(photo, "local_path")

  @doc """
  Given a photo returns it's remote path.
  """
  def get_remote_path(photo), do: get_in(photo, ["meta", "secure_url"])

  @doc """
  Given a photo returns true if it's remotely uploaded.
  """
  def is_remote(photo), do: Map.get(photo, "is_remote")

  @doc """
  Given a list of photos, returns a tuple where the first element is an array
  of previously uploaded photos and the second the one that has not yet been
  uploaded.
  """
  @spec split_old_new_photos(list(map)) :: {list(map), list(map)}
  def split_old_new_photos(photos) do
    Enum.reduce(photos, {[], []}, fn
      %{"is_remote" => is_remote} = photo, {old, new} when is_remote == false ->
        {old, new ++ [photo]}

      %{"is_remote" => is_remote} = photo, {old, new} when is_remote == true ->
        {old ++ [photo], new}
    end)
  end

  @doc """
  Given a photo and metadata, marks it as remote and assigns the metadata.
  """
  @spec mark_uplaod(map, map) :: map
  def mark_uplaod(photo, meta) do
    %{photo | "is_remote" => true, "meta" => meta}
  end

  @doc """
  Given a photo, marks it as delete
  """
  @spec mark_delete(map) :: map
  def mark_delete(photo) do
    %{photo | "delete" => true}
  end
end
