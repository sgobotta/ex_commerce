defmodule ExCommerceAssets do
  @moduledoc """
  `ExCommerceAssets` is a wrapper for assets uploading services.
  """

  @doc """
  Given a list of file paths and some options, calls upload with some fixed
  options for images format and transformation.
  """
  @spec upload_thumbnails(list(binary()), map()) :: list
  def upload_thumbnails(file_paths, options) do
    options =
      Map.merge(options, %{
        allowed_formats: "jpg, png",
        transformation: "w_512,h_512,c_limit"
      })

    upload(file_paths, options)
  end

  @doc """
  Delegates to `Cloudex.upload/2`
  """
  @spec upload([binary], map) :: list
  def upload(files, options) do
    Cloudex.upload(files, options)
    |> parse_response()
  end

  defp parse_response(upload_response) when is_list(upload_response) do
    Enum.map(upload_response, fn ok: %Cloudex.UploadedImage{} = ui ->
      ui
    end)
  end

  defp parse_response(upload_response) when is_tuple(upload_response) do
    {:ok, %Cloudex.UploadedImage{} = ui} = upload_response
    [ui]
  end
end
