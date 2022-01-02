defmodule ExCommerceWeb.LiveFormHelpers do
  @moduledoc """
  Implements reusable helpers for live forms
  """

  alias Phoenix.LiveView

  @doc """
  Given a map of params and a brand id, merges the brand id into the params.
  """
  @spec assign_brand_id_param(map(), Ecto.UUID.t()) :: map()
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
  @spec assign_uploads_param(Phoenix.LiveView.Socket.t(), map, any, keyword) ::
          map
  def assign_uploads_param(socket, params, entry_map_func, opts) do
    attr = Keyword.fetch!(opts, :attr)
    {completed, []} = LiveView.uploaded_entries(socket, attr)

    uploads_params = for entry <- completed, do: entry_map_func.(socket, entry)

    Map.merge(params, %{Atom.to_string(attr) => uploads_params})
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
  @spec redirect_or_return(Phoenix.LiveView.Socket.t()) ::
          Phoenix.LiveView.Socket.t()
  def redirect_or_return(socket) do
    case socket.assigns.redirect_to do
      nil ->
        LiveView.push_redirect(socket, to: socket.assigns.return_to)

      redirect_to ->
        LiveView.push_redirect(socket, to: redirect_to)
    end
  end
end
