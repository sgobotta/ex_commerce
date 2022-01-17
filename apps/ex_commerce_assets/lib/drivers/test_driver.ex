defmodule ExCommerceAssets.Drivers.TestDriver do
  @moduledoc """
  Test driver for the Cloudex application
  """
  @behaviour ExCommerceAssets.Driver

  @doc """
  Dummy output for `upload_thumbnails_with_options/2`
  """
  @spec upload_thumbnails_with_options(list(map()), map()) :: list()
  @impl true
  def upload_thumbnails_with_options(_items, _options) do
    [
      %Cloudex.UploadedImage{
        bytes: 9597,
        context: nil,
        created_at: "2017-08-10T09:55:32Z",
        etag: "d1ac0ee70a9a36b14887aca7f7211737",
        format: "jpg",
        height: 564,
        moderation: nil,
        original_filename: "84c3feaf-a303-4c05-97b9-ff11c8df1abd",
        phash: nil,
        public_id: "sample",
        resource_type: "image",
        secure_url:
          "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
        signature: "abcdefgc024acceb1c1baa8dca46717137fa5ae0c3",
        source:
          "/home/User/Documents/ex_commerce/_build/dev/lib/ex_commerce_web/priv/static/uploads/sample.jpg",
        tags: [],
        type: "upload",
        url:
          "http://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
        version: 1_642_370_848,
        width: 864
      }
    ]
  end

  @doc """
  Dummy output for `upload_list_with_options/2`
  """
  @spec upload_list_with_options(list(map()), map()) :: list()
  @impl true
  def upload_list_with_options(_items, _options) do
    [
      %Cloudex.UploadedImage{
        bytes: 9597,
        context: nil,
        created_at: "2017-08-10T09:55:32Z",
        etag: "d1ac0ee70a9a36b14887aca7f7211737",
        format: "jpg",
        height: 564,
        moderation: nil,
        original_filename: "84c3feaf-a303-4c05-97b9-ff11c8df1abd",
        phash: nil,
        public_id: "sample",
        resource_type: "image",
        secure_url:
          "https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
        signature: "abcdefgc024acceb1c1baa8dca46717137fa5ae0c3",
        source:
          "/home/User/Documents/ex_commerce/_build/dev/lib/ex_commerce_web/priv/static/uploads/sample.jpg",
        tags: [],
        type: "upload",
        url:
          "http://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg",
        version: 1_642_370_848,
        width: 864
      }
    ]
  end
end
