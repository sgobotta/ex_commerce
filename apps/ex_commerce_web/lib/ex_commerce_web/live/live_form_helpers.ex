defmodule ExCommerceWeb.LiveFormHelpers do
  @moduledoc """
  Implements reusable helpers for live forms
  """

  alias Phoenix.LiveView

  alias ExCommerce.Uploads
  alias ExCommerce.Uploads.Photo

  @type uuid :: Ecto.UUID.t()

  # ----------------------------------------------------------------------------
  # Defines form helpers to inject in form components
  #

  defmacro __using__(opts) do
    quote do
      require Logger

      defp get_photos(photos, opts \\ [use_placeholder: false])

      defp get_photos([], use_placeholder: true, type: type),
        do: [{:placeholder, type}]

      defp get_photos([], _opts), do: []

      defp get_photos([photo | _photos] = photos, opts) do
        case Enum.find(photos, nil, fn %Photo{state: state} ->
               state != :delete
             end) do
          nil ->
            :ok =
              Logger.warn(
                "#{__MODULE__} (get_photos/2) :: No non :delete photos found. Returning a placeholder. photos=#{
                  inspect(photos)
                }"
              )

            get_photos([], opts)

          %Photo{state: :local} = photo ->
            :ok =
              Logger.warn(
                "#{__MODULE__} (get_photos/2) :: No :uploaded photo found. Returning a local photo. photo=#{
                  inspect(photo)
                }"
              )

            [photo]

          %Photo{state: :uploaded} = photo ->
            [photo]
        end
      end

      defp get_photo_source(socket, {:placeholder, type}) do
        routes = Keyword.get(unquote(opts), :routes)
        routes.static_path(socket, get_placeholder_image(type))
      end

      defp get_photo_source(
             socket,
             %Photo{state: :local, local_path: local_path} = photo
           ) do
        routes = Keyword.get(unquote(opts), :routes)
        routes.static_path(socket, local_path)
      end

      defp get_photo_source(socket, %Photo{state: :uploaded} = photo),
        do: Photo.get_remote_path(photo)

      defp get_photo_source(socket, %Photo{state: :delete} = photo) do
        :ok =
          Logger.warn(
            "#{__MODULE__} (get_photo_source/2) :: Rendering a :delete marked photo, photo=#{
              inspect(photo)
            }"
          )

        Photo.get_remote_path(photo)
      end

      defp get_placeholder_image(:avatar),
        do: "/images/placeholders/avatar-512x512.png"

      defp get_placeholder_image(:avatar_with_size),
        do: "/images/placeholders/avatar-512x512-with-size.png"

      defp get_placeholder_image(:banner),
        do: "/images/placeholders/banner-1024x480.png"

      defp get_placeholder_image(:banner_with_size),
        do: "/images/placeholders/banner-1024x480-with-size.png"
    end
  end

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
        ) :: :ok
  def consume_uploads(socket, attr, uploads_path, upload_opts, photos) do
    consumed_entries = consume_entries(socket, attr, uploads_path)
    uploaded_images = upload_thumbnails(consumed_entries, upload_opts)

    :ok =
      Enum.each(photos, fn %Photo{} = photo ->
        attrs = maybe_mark_uploaded(photo, uploaded_images)

        {:ok, %Photo{}} = Uploads.update_photo(photo, attrs)
      end)
  end

  defp maybe_mark_uploaded(%Photo{}, []), do: %{}

  defp maybe_mark_uploaded(%Photo{uuid: uuid}, uploaded_images) do
    case Enum.find(uploaded_images, nil, fn %Cloudex.UploadedImage{
                                              original_filename:
                                                original_filename
                                            } ->
           original_filename == uuid
         end) do
      nil ->
        %{state: :delete}

      %Cloudex.UploadedImage{} = meta ->
        %{state: :uploaded, meta: Map.from_struct(meta)}
    end
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
    LiveView.consume_uploaded_entries(socket, attr, fn meta,
                                                       %LiveView.UploadEntry{
                                                         uuid: uuid
                                                       } = entry ->
      destination_path = Path.join(uploads_path, "#{uuid}.#{ext(entry)}")

      :ok = File.cp!(meta.path, destination_path)

      {destination_path, entry}
    end)
  end

  defp upload_thumbnails(entries, upload_opts) do
    items =
      Enum.map(entries, fn {file_path, %LiveView.UploadEntry{}} ->
        %{url: file_path}
      end)

    folder = Keyword.get(upload_opts, :folder)
    tags = Keyword.get(upload_opts, :tags)

    ExCommerceAssets.upload_list_with_options(items, %{
      folder: folder,
      tags: tags
    })
  end
end
