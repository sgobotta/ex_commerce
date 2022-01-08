defmodule ExCommerceAssetsTest do
  @moduledoc false

  use ExUnit.Case
  doctest ExCommerceAssets

  @tag :skip
  test "greets the world" do
    # format jpg
    # folder brand_code
    # allowed_formats [jpg, png]
    # unique_filename true
    # tags ["brand_code"]
    # transformation

    [
      ok: %Cloudex.UploadedImage{public_id: public_id_1},
      ok: %Cloudex.UploadedImage{public_id: public_id_2}
    ] =
      Cloudex.upload(
        ["test/ortiva.jpg", "test/Estaciones.jpg"],
        %{
          allowed_formats: "jpg, png",
          folder: "some_folder",
          tags: ["shop_name"],
          transformation: "w_512,h_512,c_limit"
        }
      )

    [
      ok: %Cloudex.DeletedImage{public_id: ^public_id_1},
      ok: %Cloudex.DeletedImage{public_id: ^public_id_2}
    ] = Cloudex.delete([public_id_1, public_id_2])

    Cloudex.delete(["some_folder/51fc7ea2-1b9d-4788-b41f-295c2a016e2A"])
  end
end
