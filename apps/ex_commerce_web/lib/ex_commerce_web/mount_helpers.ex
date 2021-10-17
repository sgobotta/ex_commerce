defmodule ExCommerceWeb.MountHelpers do
  @moduledoc """
  Responsible for implementing reusable mount helpers
  """
  import Phoenix.LiveView
  import ExCommerceWeb.Gettext

  alias ExCommerce.Accounts
  alias ExCommerce.Accounts.User
  alias ExCommerce.Marketplaces.{Brand, Shop}
  alias ExCommerce.Offerings.{Catalogue, CatalogueCategory, CatalogueItem}
  alias ExCommerce.Repo
  alias ExCommerceWeb.Router.Helpers, as: Routes

  @default_locale "en"
  @default_timezone "UTC"
  @default_timezone_offset 0

  @spec assign_defaults(
          Phoenix.LiveView.Socket.t(),
          any,
          nil | maybe_improper_list | map
        ) :: any
  @doc """
  Mount helper to assign defaults values to the socket. Includes: `%User{}` and
  browser locale, timezone and timezone offset.
  """
  def assign_defaults(socket, _params, session) do
    socket
    |> assign_user(session)
    |> assign_locale()
    |> assign_timezone()
    |> assign_timezone_offset()
  end

  # ----------------------------------------------------------------------------
  # Brand helpers

  @spec assign_brand_or_redirect(Phoenix.LiveView.Socket.t(), map(), map()) ::
          Phoenix.LiveView.Socket.t()
  @doc """
  Useful for `:brand_id` scoped routes or routes that need brand params
  validation.
  Checks a `brand_id` param is present to assign a valid %Brand{} to the
  socket or redirect.
  """
  def assign_brand_or_redirect(socket, %{"brand_id" => brand_id}, _session) do
    %{user: %User{brands: brands}} = socket.assigns

    case find_by(brands, :id, brand_id) do
      nil ->
        brands_redirect(socket, to: Routes.brand_index_path(socket, :index))

      %Brand{} = brand ->
        socket
        |> assign(
          :brand,
          Repo.preload(brand, [
            :shops,
            :catalogues,
            :catalogue_categories,
            :catalogue_items
          ])
        )
    end
  end

  def assign_brand_or_redirect(socket, _params, _session),
    do: brands_redirect(socket, to: Routes.brand_index_path(socket, :index))

  # ----------------------------------------------------------------------------
  # Shop helpers

  @spec assign_shop_or_redirect(Phoenix.LiveView.Socket.t(), map(), map()) ::
          Phoenix.LiveView.Socket.t()
  @doc """
  This function expects a `%Brand{shops: shops}` struct to be assigned to the
  socket, where shops are preloaded.
  Useful for `:shop_id` scoped routes or routes that need shop params
  validation.
  Checks a `shop_id` param is present to assign a valid %Shop{} to the
  socket or redirect.
  """
  def assign_shop_or_redirect(socket, %{"shop_id" => shop_id}, _session) do
    %{assigns: %{brand: %Brand{shops: shops}}} = socket

    case find_by(shops, :id, shop_id) do
      nil ->
        %{assigns: %{brand: %Brand{id: brand_id}}} = socket

        shops_redirect(socket,
          to: Routes.shop_index_path(socket, :index, brand_id)
        )

      %Shop{} = shop ->
        socket
        |> assign(:shop, shop)
    end
  end

  def assign_shop_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    shops_redirect(socket, to: Routes.shop_index_path(socket, :index, brand_id))
  end

  # ----------------------------------------------------------------------------
  # Catalogue helpers

  def assign_catalogue_or_redirect(
        socket,
        %{"catalogue_id" => catalogue_id},
        _session
      ) do
    %{assigns: %{brand: %Brand{catalogues: catalogues}}} = socket

    case find_by(catalogues, :id, catalogue_id) do
      nil ->
        %{assigns: %{brand: %Brand{id: brand_id}}} = socket

        catalogues_redirect(socket,
          to: Routes.catalogue_index_path(socket, :index, brand_id)
        )

      %Catalogue{} = catalogue ->
        socket
        |> assign(:catalogue, catalogue)
    end
  end

  def assign_catalogue_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    catalogues_redirect(socket,
      to: Routes.catalogue_index_path(socket, :index, brand_id)
    )
  end

  def assign_catalogue_category_or_redirect(
        socket,
        %{"catalogue_category_id" => catalogue_category_id},
        _session
      ) do
    %{assigns: %{brand: %Brand{catalogue_categories: catalogue_categories}}} =
      socket

    case find_by(catalogue_categories, :id, catalogue_category_id) do
      nil ->
        %{assigns: %{brand: %Brand{id: brand_id}}} = socket

        catalogue_categories_redirect(socket,
          to: Routes.catalogue_category_index_path(socket, :index, brand_id)
        )

      %CatalogueCategory{} = catalogue_category ->
        socket
        |> assign(:catalogue_category, catalogue_category)
    end
  end

  def assign_catalogue_category_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    catalogue_categories_redirect(socket,
      to: Routes.catalogue_index_path(socket, :index, brand_id)
    )
  end

  def assign_catalogue_item_or_redirect(
        socket,
        %{"catalogue_item_id" => catalogue_item_id},
        _session
      ) do
    %{assigns: %{brand: %Brand{catalogue_items: catalogue_items}}} = socket

    case find_by(catalogue_items, :id, catalogue_item_id) do
      nil ->
        %{assigns: %{brand: %Brand{id: brand_id}}} = socket

        catalogue_items_redirect(socket,
          to: Routes.catalogue_item_index_path(socket, :index, brand_id)
        )

      %CatalogueItem{} = catalogue_item ->
        socket
        |> assign(:catalogue_item, Repo.preload(catalogue_item, [:variants]))
    end
  end

  def assign_catalogue_item_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    catalogue_items_redirect(socket,
      to: Routes.catalogue_index_path(socket, :index, brand_id)
    )
  end

  # ----------------------------------------------------------------------------
  # Private helpers

  defp assign_user(socket, session) do
    %User{} =
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

  defp brands_redirect(socket, to: to) do
    socket
    |> put_flash(:error, gettext("The given brand could not be found"))
    |> redirect(to: to)
  end

  defp shops_redirect(socket, to: to) do
    socket
    |> put_flash(:error, gettext("The given shop could not be found"))
    |> redirect(to: to)
  end

  defp catalogues_redirect(socket, to: to) do
    socket
    |> put_flash(:error, gettext("The given catalogue could not be found"))
    |> redirect(to: to)
  end

  defp catalogue_categories_redirect(socket, to: to) do
    socket
    |> put_flash(
      :error,
      gettext("The given catalogue category could not be found")
    )
    |> redirect(to: to)
  end

  defp catalogue_items_redirect(socket, to: to) do
    socket
    |> put_flash(
      :error,
      gettext("The given catalogue item could not be found")
    )
    |> redirect(to: to)
  end

  defp find_by(elements, attr, value) do
    Enum.find(elements, nil, &(Map.get(&1, attr) == value))
  end
end
