defmodule ExCommerceAssets.Drivers.CloudexDriver do
  @moduledoc """
  Test driver for the Cloudex application
  """
  @behaviour ExCommerceAssets.Driver

  @doc """
  Given a list of maps with a url and cloudex option attributes, and some
  default options, calls upload with some fixed options for images format and
  transformation.

  Item options take precedence over default options.

  ## Examples

      iex> CloudexDriver.upload_thumbnails_with_options(
      ...>   [
      ...>    %{url: "path/to/my/file", folder: "this item folder"},
      ...>    %{url: "path/to/my/file", tags: ["summer", "2022"]}
      ...>   ],
      ...>   %{folder: "this-folder-name-is-overwritten-for-the-first-item"}
      ...> )
      [%Cloudex.UploadedImage{}]

  """
  @spec upload_thumbnails_with_options(list(map()), map()) :: list()
  @impl true
  def upload_thumbnails_with_options(items, options) do
    options =
      Map.merge(options, %{
        allowed_formats: "jpg, png",
        transformation: "w_512,h_512,c_limit"
      })

    __MODULE__.upload_list_with_options(items, options)
  end

  @doc """
  Given a list of maps with a url and cloudex option attributes, and some
  default options, deletes to Cloudex to upload many images.

  Item options take precedence over default options.

  ## Examples

      iex> CloudexDriver.upload_list_with_options(
      ...>   [
      ...>    %{url: "path/to/my/file", folder: "this item folder"},
      ...>    %{url: "path/to/my/file", tags: ["summer", "2022"]}
      ...>   ],
      ...>   %{folder: "this-folder-name-is-overwritten-for-the-first-item"}
      ...> )
      [%Cloudex.UploadedImage{}]

  """
  @spec upload_list_with_options(list(map()), map()) :: list()
  @impl true
  def upload_list_with_options(items, options) do
    Cloudex.upload_list_with_options(items, options)
    |> parse_response()
  end

  defp parse_response(upload_response) when is_list(upload_response) do
    Enum.map(upload_response, fn {:ok, %Cloudex.UploadedImage{} = ui} ->
      ui
    end)
  end
end
