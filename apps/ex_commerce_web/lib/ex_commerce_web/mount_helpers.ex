defmodule ExCommerceWeb.MountHelpers do
  @moduledoc """
  Responsible for implementing reusable mount helpers
  """
  import Phoenix.LiveView

  alias ExCommerce.Accounts

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

  def assign_brand(socket, %{"brand" => brand}, _session) do
    socket
    |> assign(:brand, brand)
  end

  def assign_brand(socket, params, _session) do
    # Find and assign the default brand
    socket
    |> assign(:brand, "12")
  end

  defp assign_user(socket, session) do
    user = Accounts.get_user_by_session_token(session["user_token"])

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
