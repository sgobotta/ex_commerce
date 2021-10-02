defmodule ExCommerceWeb.BrandLive.Show do
  @moduledoc """
  Shows a single brand
  """
  use ExCommerceWeb, :live_view

  alias ExCommerce.Marketplaces.Brand

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok, assign_defaults(socket, params, session)}

      false ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _session, socket) do
    case connected?(socket) do
      true ->
        case Enum.find(socket.assigns.user.brands, nil, &(&1.id == id)) do
          nil ->
            {:noreply,
             socket
             |> put_flash(:error, gettext("The given shop could not be found"))
             |> redirect(to: Routes.brand_index_path(socket, :index))}

          %Brand{} = brand ->
            {:noreply,
             socket
             |> assign(:page_title, page_title(socket.assigns.live_action))
             |> assign(:brand, brand)}
        end

      false ->
        {:noreply, socket}
    end
  end

  defp page_title(:show), do: "Show Brand"
  defp page_title(:edit), do: "Edit Brand"
end
