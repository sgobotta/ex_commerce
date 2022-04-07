defmodule ExCommerceWeb.MountHelpers do
  @moduledoc """
  Responsible for implementing reusable mount helpers
  """
  import Phoenix.LiveView
  import ExCommerceWeb.Gettext

  alias ExCommerce.Accounts
  alias ExCommerce.Accounts.User
  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.{Brand, Shop}
  alias ExCommerce.Offerings

  alias ExCommerce.Offerings.{
    Catalogue,
    CatalogueCategory,
    CatalogueItem,
    CatalogueItemOptionGroup
  }

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
  def assign_defaults(socket, params, session) do
    socket
    |> assign_user(session)
    |> assign_locale()
    |> assign_timezone()
    |> assign_timezone_offset()
    |> assign_navigation_helpers(params)
  end

  # ============================================================================
  # Helpers belong can be used in Places pages
  #

  # ----------------------------------------------------------------------------
  # Navigation helpers

  defp assign_navigation_helpers(socket, params) do
    socket
    |> assign(:redirect_to, params["redirect_to"])
  end

  # ----------------------------------------------------------------------------
  # Brand helpers

  def assign_brands(socket) do
    socket
    |> assign(:brands, Marketplaces.list_brands())
  end

  def assign_brand_by_slug_or_redirect(socket, %{"brand" => slug}) do
    case Marketplaces.get_brand_by(:slug, slug) do
      nil ->
        redirect_with_flash(
          socket,
          to: Routes.place_search_path(socket, :search),
          kind: :info,
          message: gettext("Choose a brand")
        )

      %Brand{} = brand ->
        socket
        |> assign(:brand, Repo.preload(brand, shops: [:avatars, :banners]))
    end
  end

  def assign_place_by_slug_or_redirect(socket, %{
        "brand" => brand_slug,
        "shop" => shop_slug
      }) do
    case Marketplaces.get_shop_by_brand_slug(brand_slug, shop_slug) do
      nil ->
        redirect_with_flash(
          socket,
          to: Routes.place_search_path(socket, :search),
          kind: :info,
          message: gettext("Choose a shop")
        )

      %Shop{} = shop ->
        socket
        |> assign(
          :shop,
          Repo.preload(
            shop,
            avatars: [],
            banners: [],
            catalogues: [
              categories: [
                items: [
                  option_groups: [],
                  photos: [],
                  variants: []
                ]
              ]
            ]
          )
        )
    end
  end

  def assign_catalogue_by_id_or_redirect(socket, catalogue_id) do
    case Offerings.get_catalogue(catalogue_id) do
      nil ->
        redirect_with_flash(
          socket,
          to:
            Routes.place_show_path(
              socket,
              :show,
              socket.assigns.brand.id,
              socket.assigns.shop.id
            ),
          kind: :info,
          message: gettext("Choose a catalogue")
        )

      %Catalogue{} = catalogue ->
        socket
        |> assign(
          :catalogue,
          Repo.preload(
            catalogue,
            categories: [
              items: [
                option_groups: [],
                photos: [],
                variants: []
              ]
            ]
          )
        )
    end
  end

  def assign_catalogue_item_by_id_or_redirect(socket, catalogue_item_id) do
    case Offerings.get_catalogue_item(catalogue_item_id) do
      nil ->
        redirect_with_flash(
          socket,
          to:
            Routes.place_show_path(
              socket,
              :show_catalogue,
              socket.assigns.brand.id,
              socket.assigns.shop.id,
              socket.assigns.catalogue.id
            ),
          kind: :info,
          message:
            gettext("The item could not be found, please choose another one.")
        )

      %CatalogueItem{} = catalogue_item ->
        socket
        |> assign(
          :catalogue_item,
          Repo.preload(
            catalogue_item,
            option_groups: [],
            photos: [],
            variants: []
          )
        )
    end
  end

  # ============================================================================
  # Helpers below belong and should be used for Admin pages only
  #

  # ----------------------------------------------------------------------------
  # Brands helpers

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
          Repo.preload(brand,
            shops: [:avatars, :banners],
            catalogues: [:categories],
            catalogue_categories: [:items, :catalogues],
            catalogue_items: [:variants, :photos],
            catalogue_item_option_groups: []
          )
        )
    end
  end

  def assign_brand_or_redirect(socket, _params, _session),
    do: brands_redirect(socket, to: Routes.brand_index_path(socket, :index))

  # ----------------------------------------------------------------------------
  # Shops helpers

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
  # Catalogues helpers

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
        |> assign(
          :catalogue,
          Repo.preload(catalogue, [:categories, :shops])
        )
    end
  end

  def assign_catalogue_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    catalogues_redirect(socket,
      to: Routes.catalogue_index_path(socket, :index, brand_id)
    )
  end

  # ----------------------------------------------------------------------------
  # Catalogue categories helpers

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
        |> assign(
          :catalogue_category,
          Repo.preload(catalogue_category, [:items, :catalogues])
        )
    end
  end

  def assign_catalogue_category_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    catalogue_categories_redirect(socket,
      to: Routes.catalogue_index_path(socket, :index, brand_id)
    )
  end

  # ----------------------------------------------------------------------------
  # Catalogue items helpers

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
        |> assign(
          :catalogue_item,
          Repo.preload(catalogue_item, [:variants, :option_groups, :categories])
        )
    end
  end

  def assign_catalogue_item_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    catalogue_items_redirect(socket,
      to: Routes.catalogue_index_path(socket, :index, brand_id)
    )
  end

  # ----------------------------------------------------------------------------
  # Catalogue item option groups helpers

  def assign_catalogue_item_option_group_or_redirect(
        socket,
        %{"catalogue_item_option_group_id" => catalogue_item_option_group_id},
        _session
      ) do
    %{
      assigns: %{
        brand: %Brand{
          catalogue_item_option_groups: catalogue_item_option_groups
        }
      }
    } = socket

    case find_by(
           catalogue_item_option_groups,
           :id,
           catalogue_item_option_group_id
         ) do
      nil ->
        %{assigns: %{brand: %Brand{id: brand_id}}} = socket

        catalogue_item_option_groups_redirect(socket,
          to:
            Routes.catalogue_item_option_group_index_path(
              socket,
              :index,
              brand_id
            )
        )

      %CatalogueItemOptionGroup{} = catalogue_item_option_group ->
        socket
        |> assign(
          :catalogue_item_option_group,
          Repo.preload(catalogue_item_option_group, [:options, :items])
        )
    end
  end

  def assign_catalogue_item_option_group_or_redirect(socket, _params, _session) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    catalogue_item_option_groups_redirect(socket,
      to:
        Routes.catalogue_item_option_group_index_path(socket, :index, brand_id)
    )
  end

  # ----------------------------------------------------------------------------
  # Private helpers

  defp assign_user(socket, %{"user_token" => user_token} = _session) do
    case Accounts.get_user_by_session_token(user_token) do
      %User{} = user ->
        user
        |> Repo.preload([:brands])

        assign(socket, :user, user)

      nil ->
        assign_user(socket, %{})
    end
  end

  defp assign_user(socket, _session) do
    %User{} = user = %User{} |> Repo.preload([:brands])

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

  defp redirect_with_flash(socket, to: to, kind: kind, message: message) do
    socket
    |> put_flash(kind, message)
    |> redirect(to: to)
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

  defp catalogue_item_option_groups_redirect(socket, to: to) do
    socket
    |> put_flash(
      :error,
      gettext("The given catalogue item option group could not be found")
    )
    |> redirect(to: to)
  end

  defp find_by(elements, attr, value) do
    Enum.find(elements, nil, &(Map.get(&1, attr) == value))
  end
end
