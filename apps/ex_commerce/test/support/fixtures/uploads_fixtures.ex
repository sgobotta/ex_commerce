defmodule ExCommerce.UploadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExCommerce.Uploads` context.
  """

  @doc """
  Generate a photo.
  """
  def photo_fixture(attrs \\ %{}) do
    {:ok, photo} =
      attrs
      |> Enum.into(%{
        full_local_path: "some full_local_path",
        local_path: "some local_path",
        meta: %{},
        state: :local,
        type: :avatar,
        uuid: "some uuid"
      })
      |> ExCommerce.Uploads.create_photo()

    photo
  end
end
