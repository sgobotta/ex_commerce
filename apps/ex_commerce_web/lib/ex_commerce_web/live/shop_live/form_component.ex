defmodule ExCommerceWeb.ShopLive.FormComponent do
  @moduledoc """
  Form for shops create/edit actions
  """

  use ExCommerceWeb, :live_component

  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Shop

  @app_host System.get_env("APP_HOST")

  @impl true
  def update(%{shop: shop} = assigns, socket) do
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

  defp save_shop(socket, :edit, shop_params) do
    case Marketplaces.update_shop(socket.assigns.shop, shop_params) do
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
    shop_params = Map.merge(shop_params, %{"brand_id" => brand_id})

    case Marketplaces.create_shop(shop_params) do
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
end
