defmodule ExCommerceWeb.CatalogueLive.Index do
  @moduledoc """
  Lists available catalogues
  """

  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces.Brand
  alias ExCommerce.Offerings
  alias ExCommerce.Offerings.Catalogue
  alias ExCommerce.Repo

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign_defaults(params, session)
         |> assign_brand_or_redirect(params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"brand_id" => _brand_id} = params, _url, socket) do
    socket =
      case connected?(socket) do
        true ->
          %{assigns: %{brand: %Brand{catalogues: catalogues}}} = socket

          socket
          |> assign(:catalogues, catalogues)
          |> apply_action(socket.assigns.live_action, params)

        false ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext("Please Manage a brand to continue browsing catalogues")
     )
     |> redirect(to: Routes.brand_index_path(socket, :index))}
  end

  defp apply_action(socket, :edit, %{"catalogue_id" => _catalogue_id} = params) do
    socket
    |> assign(:page_title, gettext("Edit Catalogue"))
    |> assign_catalogue_or_redirect(params, %{})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Catalogue"))
    |> assign(:catalogue, prepare_new_catalogue(socket.assigns))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Catalogues"))
    |> assign(:catalogue, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => catalogue_id}, socket) do
    %{assigns: %{brand: %Brand{id: brand_id}}} = socket

    %Catalogue{} = catalogue = Offerings.get_catalogue!(catalogue_id)
    {:ok, _} = Offerings.delete_catalogue(catalogue)

    {:noreply, assign(socket, :catalogues, list_catalogues(brand_id))}
  end

  defp prepare_new_catalogue(%{brand: %Brand{id: brand_id}}) do
    %Catalogue{brand_id: brand_id}
    |> Repo.preload([:categories])
  end

  defp list_catalogues(brand_id) do
    Offerings.list_catalogues_by_brand(brand_id)
  end
end
