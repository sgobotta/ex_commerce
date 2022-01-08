defmodule ExCommerceWeb.LiveFormHelpers do
  @moduledoc """
  Implements reusable helpers for live forms
  """

  alias Phoenix.LiveView

  alias ExCommerce.Photos

  @type uuid :: Ecto.UUID.t()

  @doc """
  Given a map of params and a brand id, merges the brand id into the params.
  """
  @spec assign_brand_id_param(map(), uuid()) :: map()
  def assign_brand_id_param(%{"options" => options} = params, brand_id) do
    options =
      options
      |> Enum.reduce(%{}, fn {key, value}, acc ->
        Map.put(acc, key, Map.merge(value, %{"brand_id" => brand_id}))
      end)

    Map.merge(params, %{"brand_id" => brand_id, "options" => options})
  end

  def assign_brand_id_param(params, brand_id),
    do: Map.merge(params, %{"brand_id" => brand_id})

  @doc """
  Given a socket, some parms, a function and some options, retrieves completed
  upload entries and merges the entry function output into the given params to
  return a new map.
  """
  @spec put_uploads(
          LiveView.Socket.t(),
          map,
          (LiveView.Socket.t(), LiveView.UploadEntry.t() -> map),
          (LiveView.Socket.t(), list(map) -> list(map)),
          keyword
        ) ::
          map
  def put_uploads(
        socket,
        params,
        entry_map_func,
        assign_attr_func,
        opts
      ) do
    attr = Keyword.fetch!(opts, :attr)
    {completed, []} = LiveView.uploaded_entries(socket, attr)

    entries =
      for %LiveView.UploadEntry{} = entry <- completed,
          do: entry_map_func.(socket, entry)

    Map.put(params, Atom.to_string(attr), assign_attr_func.(socket, entries))
  end

  @doc """
  Given a socket, a form changeset attribute, an uploads path, uploads options
  and a list of photos, consumes uploaded entries to copy them locally and sends
  them for uploading to the Assets application to returns a tuple where the
  first element is a list of uploaded photos and the second element is a list
  of already uploaded photos.
  """
  @spec consume_uploads(
          LiveView.Socket.t(),
          atom,
          binary(),
          keyword(),
          list(map)
        ) :: {[map], [map]}
  def consume_uploads(socket, attr, uploads_path, upload_opts, photos) do
    destination_paths = consume_entries(socket, attr, uploads_path)

    uploaded_images = upload_thumbnails(destination_paths, upload_opts)

    {old_photos, new_photos} = Photos.split_old_new_photos(photos)

    new_photos =
      new_photos
      |> Enum.zip(uploaded_images)
      |> Enum.map(fn {photo, %Cloudex.UploadedImage{} = meta} ->
        Photos.mark_uplaod(photo, Map.from_struct(meta))
      end)

    old_photos = Enum.map(old_photos, &Photos.mark_delete(&1))

    {new_photos, old_photos}
  end

  @doc """
  Given an entry returns a valid MIME extension.
  """
  @spec ext(%{:client_type => binary, optional(any) => any}) :: binary
  def ext(%{client_type: client_type}), do: hd(MIME.extensions(client_type))

  @doc """
  Given a socket, attempts to navigate to a `:redirect_to` assign, otherwise
  navigates to the `:return_to` assign.
  """
  @spec redirect_or_return(LiveView.Socket.t()) :: LiveView.Socket.t()
  def redirect_or_return(socket) do
    case socket.assigns.redirect_to do
      nil ->
        LiveView.push_redirect(socket, to: socket.assigns.return_to)

      redirect_to ->
        LiveView.push_redirect(socket, to: redirect_to)
    end
  end

  # ----------------------------------------------------------------------------
  # Private helpers
  #

  defp consume_entries(socket, attr, uploads_path) do
    LiveView.consume_uploaded_entries(socket, attr, fn meta, entry ->
      destination_path = Path.join(uploads_path, "#{entry.uuid}.#{ext(entry)}")

      :ok = File.cp!(meta.path, destination_path)

      destination_path
    end)
  end

  defp upload_thumbnails(destination_paths, upload_opts) do
    folder = Keyword.get(upload_opts, :folder)
    tags = Keyword.get(upload_opts, :tags)

    ExCommerceAssets.upload_thumbnails(destination_paths, %{
      folder: folder,
      tags: tags
    })
  end
end
