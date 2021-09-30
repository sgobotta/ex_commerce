defmodule ExCommerceWeb.MountHelpers do
  @moduledoc """
  Responsible for implementing reusable mount helpers
  """
  import Phoenix.LiveView

  alias ExCommerce.Accounts
  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Repo
  alias ExCommerceWeb.Router.Helpers, as: Routes

  @default_locale "en"
  @default_timezone "UTC"
  @default_timezone_offset 0

  @doc """
  Mount helper to assign defaults values to the socket. Includes: `%User{}` and
  browser locale, timezone and timezone offset.
  """
  def assign_defaults(socket, _params, session) do
    case connected?(socket) do
      true ->
        socket
        |> assign_user(session)
        |> assign_locale()
        |> assign_timezone()
        |> assign_timezone_offset()

      false ->
        socket
    end
  end

  def assign_brand(socket, %{"brand" => brand_id}, _session) do
    %{user: %{brands: brands}} = socket.assigns

    case Enum.find(brands, nil, &(&1.id == brand_id)) do
      nil ->
        socket
        |> redirect(to: Routes.brand_index_path(socket, :new))

      %Brand{id: brand_id} ->
        socket
        |> assign(:brand, brand_id)
    end
  end

  def assign_brand(socket, _params, _session) do
    # Find and assign the first found brand
    %{user: %{brands: brands}} = socket.assigns

    case Enum.at(brands, 0) do
      nil ->
        socket
        |> redirect(to: Routes.brand_index_path(socket, :new))

      brand ->
        socket
        |> assign(:brand, brand.id)
    end
  end

  defp assign_user(socket, session) do
    user =
      Accounts.get_user_by_session_token(session["user_token"])
      |> Repo.preload([:brands])

    socket
    |> assign_new(:user, fn -> user end)
  end

  defp assign_locale(socket) do
    locale = get_connect_params(socket)["locale"] || @default_locale
    assign(socket, locale: locale)
  end

  defp assign_timezone(socket) do
    timezone = get_connect_params(socket)["timezone"] || @default_timezone
    assign(socket, timezone: timezone)
  end

  defp assign_timezone_offset(socket) do
    timezone_offset =
      get_connect_params(socket)["timezone_offset"] || @default_timezone_offset

    assign(socket, timezone_offset: timezone_offset)
  end
end
