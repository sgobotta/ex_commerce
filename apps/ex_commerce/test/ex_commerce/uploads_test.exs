defmodule ExCommerce.UploadsTest do
  use ExCommerce.DataCase

  alias ExCommerce.Uploads

  describe "photos" do
    alias ExCommerce.Uploads.Photo

    import ExCommerce.UploadsFixtures

    @invalid_attrs %{
      full_local_path: nil,
      local_path: nil,
      meta: nil,
      state: nil,
      type: nil,
      uuid: nil
    }

    test "list_photos/0 returns all photos" do
      photo = photo_fixture()
      assert Uploads.list_photos() == [photo]
    end

    test "get_photo!/1 returns the photo with given id" do
      photo = photo_fixture()
      assert Uploads.get_photo!(photo.id) == photo
    end

    test "create_photo/1 with valid data creates a photo" do
      valid_attrs = %{
        full_local_path: "some full_local_path",
        local_path: "some local_path",
        meta: %{},
        state: :local,
        type: :avatar,
        uuid: "some uuid"
      }

      assert {:ok, %Photo{} = photo} = Uploads.create_photo(valid_attrs)
      assert photo.full_local_path == "some full_local_path"
      assert photo.local_path == "some local_path"
      assert photo.meta == %{}
      assert photo.state == :local
      assert photo.type == :avatar
      assert photo.uuid == "some uuid"
    end

    test "create_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Uploads.create_photo(@invalid_attrs)
    end

    test "update_photo/2 with valid data updates the photo" do
      photo = photo_fixture()

      update_attrs = %{
        full_local_path: "some updated full_local_path",
        local_path: "some updated local_path",
        meta: %{},
        state: :uploaded,
        type: :banner,
        uuid: "some updated uuid"
      }

      assert {:ok, %Photo{} = photo} = Uploads.update_photo(photo, update_attrs)
      assert photo.full_local_path == "some updated full_local_path"
      assert photo.local_path == "some updated local_path"
      assert photo.meta == %{}
      assert photo.state == :uploaded
      assert photo.type == :banner
      assert photo.uuid == "some updated uuid"
    end

    test "update_photo/2 with invalid data returns error changeset" do
      photo = photo_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Uploads.update_photo(photo, @invalid_attrs)

      assert photo == Uploads.get_photo!(photo.id)
    end

    test "delete_photo/1 deletes the photo" do
      photo = photo_fixture()
      assert {:ok, %Photo{}} = Uploads.delete_photo(photo)
      assert_raise Ecto.NoResultsError, fn -> Uploads.get_photo!(photo.id) end
    end

    test "change_photo/1 returns a photo changeset" do
      photo = photo_fixture()
      assert %Ecto.Changeset{} = Uploads.change_photo(photo)
    end
  end
end
