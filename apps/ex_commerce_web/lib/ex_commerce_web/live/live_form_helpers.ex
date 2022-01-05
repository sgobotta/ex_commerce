defmodule ExCommerceWeb.LiveFormHelpers do
  @moduledoc """
  Implements reusable helpers for live forms
  """

  alias Phoenix.LiveView

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
  @spec assign_uploads_param(
          LiveView.Socket.t(),
          map,
          (LiveView.Socket.t(), LiveView.UploadEntry.t() -> map),
          (LiveView.Socket.t(), list(map) -> list(map)),
          keyword
        ) ::
          map
  def assign_uploads_param(
        socket,
        params,
        entry_map_func,
        assign_attr_func,
        opts
      ) do
    attr = Keyword.fetch!(opts, :attr)
    {completed, []} = LiveView.uploaded_entries(socket, attr)

    uploads_params = for entry <- completed, do: entry_map_func.(socket, entry)

    Map.merge(
      params,
      %{Atom.to_string(attr) => assign_attr_func.(socket, uploads_params)}
    )
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
end
