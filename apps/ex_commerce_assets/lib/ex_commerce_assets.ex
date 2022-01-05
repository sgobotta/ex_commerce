defmodule ExCommerceAssets do
  @moduledoc """
  `ExCommerceAssets` is a wrapper for assets uploading services.
  """

  @doc """
  Delegates to `Cloudex.upload/2`
  """
  @spec upload([binary], map) :: list
  def upload(files, options) do
    Cloudex.upload(files, options)
    |> parse_response()
  end

  def hello do
    :world
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
