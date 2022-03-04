defmodule ExCommerceWeb.BrandLive.Index do
  @moduledoc """
  Lists available brands
  """
  use ExCommerceWeb,
      {:live_view,
       layout: {ExCommerceWeb.LayoutView, "live_brands_dashboard.html"}}

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
  def handle_params(params, _url, socket) do
    {:noreply, apply_action_maybe(socket, socket.assigns.live_action, params)}
  end

  defp apply_action_maybe(socket, live_action, params) do
    case connected?(socket) do
      true ->
        apply_action(socket, live_action, params)

      false ->
        socket
    end
  end

  defp apply_action(socket, :edit, %{"brand_id" => _brand_id} = params) do
    socket
    |> assign(:page_title, gettext("Edit Brand"))
    |> assign_brand_or_redirect(params, %{})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Brand"))
    |> assign(:brand, %Brand{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Brands"))
    |> assign(:brand, nil)
  end

  @impl true
  def handle_event("delete", %{"brand_id" => id}, socket) do
    %Brand{} = brand = Marketplaces.get_brand!(id)
    {:ok, _} = Marketplaces.delete_brand(brand)

    {:noreply, assign(socket, :brands, list_brands())}
  end

  defp list_brands do
    Marketplaces.list_brands()
  end
end
