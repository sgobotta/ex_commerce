defmodule ExCommerceWeb.BrandLive.Index do
  @moduledoc """
  Lists available brands
  """
  use ExCommerceWeb, :live_view

  alias ExCommerce.Accounts.User
  alias ExCommerce.Marketplaces
  alias ExCommerce.Marketplaces.Brand

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        %{assigns: %{user: %User{brands: brands}}} =
          socket = assign_defaults(socket, params, session)

        {:ok,
         socket
         |> assign(:brands, brands)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => _brand_id} = params, _url, socket) do
    socket =
      case connected?(socket) do
        true ->
          socket
          |> apply_action(socket.assigns.live_action, params)

        false ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => brand_id}) do
    %{assigns: %{user: %User{brands: brands}}} = socket

    case Enum.find(brands, nil, &(&1.id == brand_id)) do
      nil ->
        socket
        |> put_flash(:error, gettext("The given brand could not be found"))
        |> redirect(to: Routes.brand_index_path(socket, :index))

      brand ->
        socket
        |> assign(:page_title, "Edit Brand")
        |> assign(:brand, brand)
    end
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Brand")
    |> assign(:brand, %Brand{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Brands")
    |> assign(:brand, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    brand = Marketplaces.get_brand!(id)
    {:ok, _} = Marketplaces.delete_brand(brand)

    {:noreply, assign(socket, :brands, list_brands())}
  end

  defp list_brands do
    Marketplaces.list_brands()
  end
end
