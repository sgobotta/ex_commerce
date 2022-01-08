defmodule ExCommerceWeb.ShopLive.FormComponent do
  @moduledoc """
  Form for shops create/edit actions
  """

  use ExCommerceWeb, :live_component

  use ExCommerceWeb.LiveFormHelpers, routes: Routes

  alias ExCommerce.{Marketplaces, Photos}
  alias ExCommerce.Marketplaces.{Brand, Shop}

  import ExCommerceWeb.{
    LiveFormHelpers,
    Utils
  }

  @app_host System.get_env("APP_HOST")

  @uploads_path get_uploads_path()

  @impl true
  @spec mount(Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(socket) do
    {:ok,
     socket
     |> allow_upload(
       :avatars,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 2_000_000,
       auto_upload: true
     )
     |> allow_upload(
       :banners,
       accept: ~w(.jpg .jpeg .png),
       max_entries: 1,
       max_file_size: 2_000_000,
       auto_upload: true
     )}
  end

  @impl true
  def update(%{shop: %Shop{} = shop} = assigns, socket) do
    changeset = Marketplaces.change_shop(shop)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign_slug_placeholder()}
  end

  @impl true
  def handle_event("validate", %{"shop" => shop_params}, socket) do
    changeset =
      socket.assigns.shop
      |> Marketplaces.change_shop(shop_params)
      |> Map.put(:action, :validate)

    {:noreply,
     assign(socket, :changeset, changeset)
     |> assign_slug_placeholder()}
  end

  def handle_event("save", %{"shop" => shop_params}, socket) do
    save_shop(socket, socket.assigns.action, shop_params)
  end

  def handle_event("cancel_avatar_entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatars, ref)}
  end

  def handle_event("cancel_banner_entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :banners, ref)}
  end

  # ----------------------------------------------------------------------------
  # Private helpers
  #

  defp save_shop(socket, :edit, shop_params) do
    shop_params =
      put_uploads(
        socket,
        shop_params,
        &build_avatar_by_upload_entry/2,
        &assign_avatars_param/2,
        attr: :avatars
      )

    shop_params =
      put_uploads(
        socket,
        shop_params,
        &build_banner_by_upload_entry/2,
        &assign_banners_param/2,
        attr: :banners
      )

    case Marketplaces.update_shop(
           socket.assigns.shop,
           shop_params,
           &consume_media_files(socket, &1)
         ) do
      {:ok, %Shop{} = _shop} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Shop updated successfully"))
         |> push_redirect(to: socket.assigns.patch_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_shop(socket, :new, shop_params) do
    %{assigns: %{shop: %Shop{brand_id: brand_id}}} = socket

    shop_params =
      put_uploads(
        socket,
        shop_params,
        &build_avatar_by_upload_entry/2,
        &assign_avatars_param/2,
        attr: :avatars
      )
      |> assign_brand_id_param(brand_id)

    case Marketplaces.create_shop(
           shop_params,
           &consume_media_files(socket, &1)
         ) do
      {:ok, %Shop{} = _shop} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Shop created successfully"))
         |> push_redirect(to: socket.assigns.patch_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_slug_placeholder(socket) do
    %{assigns: %{changeset: %Ecto.Changeset{changes: changes}}} = socket

    base_placeholder =
      gettext("Your shop will be available at %{host}/", host: @app_host)

    placeholder =
      case Map.has_key?(changes, :slug) do
        true ->
          slug = Map.get(changes, :slug)
          base_placeholder <> slug

        false ->
          %{assigns: %{shop: %Shop{slug: slug}}} = socket
          base_placeholder <> (slug || "")
      end

    assign(socket, :slug_placeholder, placeholder)
  end

  # ----------------------------------------------------------------------------
  # File upload helpers
  #

  defp build_avatar_by_upload_entry(socket, entry) do
    %{brand: %Brand{id: brand_id}} = socket.assigns
    %{uuid: uuid} = entry
    extension = ext(entry)

    Photos.create_photo(%{
      local_path: Routes.static_path(socket, "/uploads/#{uuid}.#{extension}"),
      full_local_path: Path.join(@uploads_path, "#{uuid}.#{extension}"),
      uuid: uuid,
      brand_id: brand_id
    })
  end

  defp assign_avatars_param(socket, new_avatars) do
    %{shop: %Shop{avatars: avatars}} = socket.assigns

    new_avatars ++ avatars
  end

  defp build_banner_by_upload_entry(socket, entry) do
    %{brand: %Brand{id: brand_id}} = socket.assigns
    %{uuid: uuid} = entry
    extension = ext(entry)

    Photos.create_photo(%{
      local_path: Routes.static_path(socket, "/uploads/#{uuid}.#{extension}"),
      full_local_path: Path.join(@uploads_path, "#{uuid}.#{extension}"),
      uuid: uuid,
      brand_id: brand_id
    })
  end

  defp assign_banners_param(socket, new_banners) do
    %{shop: %Shop{banners: banners}} = socket.assigns

    new_banners ++ banners
  end

  defp consume_media_files(
         socket,
         %Shop{avatars: avatars, banners: banners} = shop
       ) do
    %{brand: %Brand{id: brand_id}} = socket.assigns
    upload_opts = [folder: brand_id, tags: brand_id]

    # Consumes uploads via the live form helper
    {old_avatars, new_avatars} =
      consume_uploads(
        socket,
        :avatars,
        @uploads_path,
        upload_opts,
        avatars
      )

    {old_banners, new_banners} =
      consume_uploads(
        socket,
        :banners,
        @uploads_path,
        upload_opts,
        banners
      )

    # Saves new avatars and banners
    {:ok, %Shop{} = shop} =
      Marketplaces.update_shop(shop, %{
        avatars: new_avatars ++ old_avatars,
        banners: new_banners ++ old_banners
      })

    {:ok, shop}
  end
end
