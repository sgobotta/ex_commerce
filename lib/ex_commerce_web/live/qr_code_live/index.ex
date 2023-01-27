defmodule ExCommerceWeb.QrCodeLive.Index do
  @moduledoc """
  Lists QR Codes for shops and catalogues
  """

  use ExCommerceWeb, {
    :live_view,
    layout: {ExCommerceWeb.LayoutView, :live_main_dashboard}
  }

  alias ExCommerce.Marketplaces.Shop
  alias ExCommerce.Offerings.Catalogue

  alias ExCommerceWeb.Router.Helpers, as: Routes

  @impl true
  def render(assigns) do
    ~H"""
    <div class="dashboard-container">
      <h1 class="user-form section-title-lg">
        <%= gettext("QR Codes") %>
      </h1>

      <p class="pb-2 text-lg form-field-description">
        <%= gettext("Generate QR codes for your shop and menus/catalogues.") %>
      </p>

      <div class="flex flex-row pb-2">
        <div class="pt-1">
          <.icon name={:information_circle} outlined class="
            text-gray-500
            flex-shrink-0 h-4 w-4
          "/>
        </div>
        <div class="">
          <p class="form-field-hint">
            <%= gettext("These are printable codes that can be useful to quickly present menus to your customers by scanning them from a mobile phone.") %>
          </p>
        </div>
      </div>

      <div class="flex flex-row pb-2">
        <div class="pt-1">
          <.icon name={:exclamation_circle} outlined class="
            text-yellow-500
            flex-shrink-0 h-4 w-4
          "/>
        </div>
        <div class="">
          <p class="form-field-hint text-yellow-500">
            <%= gettext("Note that deleting a shop or menu will cause any printed QR code to fail finding the link to your online shop.") %>
          </p>
        </div>
      </div>

      <div id="qr_codes">
        <%= for %Shop{brand_id: brand_id, catalogues: catalogues, id: shop_id, name: shop_name} <- @brand.shops do %>
          <div class="my-4">
            <h2 class="user-form section-subtitle">
              <%= shop_name %>
            </h2>
          </div>
          <div class="grid grid-cols-2 grid-flow-row gap-4">
            <div class="justify-self-center">
              <div class="flex justify-center">
                <div class="card p-2">
                  <.with_tooltip text={gettext("Download")}>
                    <.qr_code
                      color={<<255,0,0>>}
                      content={generate_shop_url(brand_id, shop_id)}
                      filename={get_filename("shop-#{shop_name}")}
                      type={:svg}
                      width={100}
                    />
                  </.with_tooltip>
                </div>
              </div>
              <div class="inline-flex items-center">
                <div>
                  <.icon name={:building_storefront} outlined class="
                    text-rose-500
                    h-6 w-6
                  "/>
                </div>
                <div class="pb-1">
                  <span class="text-base font-normal">Shop QR</span>
                </div>
              </div>
            </div>
            <%= for %Catalogue{id: catalogue_id, name: catalogue_name} <- catalogues do %>
              <div class="justify-self-center">
                <div class="flex justify-center">
                  <div class="card p-2">
                    <.with_tooltip text={gettext("Download")}>
                      <.qr_code
                        color={<<255,0,0>>}
                        content={generate_catalogue_url(brand_id, shop_id, catalogue_id)}
                        filename={get_filename("shop-#{shop_name}-catalogue-#{catalogue_name}")}
                        type={:svg}
                        width={100}
                      />
                    </.with_tooltip>
                  </div>
                </div>
                <div class="inline-flex items-center">
                  <div>
                    <.icon name={:book_open} outlined class="
                      text-rose-500
                      h-6 w-6
                    "/>
                  </div>
                  <div class="pb-2">
                    <span class="text-base font-normal"><%= catalogue_name %></span>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        {:ok,
         socket
         |> assign(:host, ExCommerceWeb.host())
         |> assign_defaults(params, session)
         |> assign_brand_or_redirect(params, session,
           preload_fields: [shops: [:catalogues]]
         )}

      false ->
        {:ok, socket}
    end
  end

  @spec generate_shop_url(Ecto.UUID.t(), Ecto.UUID.t()) :: String.t()
  defp generate_shop_url(brand_id, shop_id) do
    Routes.checkout_shop_path(ExCommerceWeb.Endpoint, :index, brand_id, shop_id)
    |> join_host()
  end

  @spec generate_catalogue_url(Ecto.UUID.t(), Ecto.UUID.t(), Ecto.UUID.t()) ::
          String.t()
  defp generate_catalogue_url(brand_id, shop_id, catalogue_id) do
    Routes.checkout_catalogue_path(
      ExCommerceWeb.Endpoint,
      :index,
      brand_id,
      shop_id,
      catalogue_id
    )
    |> join_host()
  end

  @spec join_host(String.t()) :: String.t()
  defp join_host(path), do: Path.join(ExCommerceWeb.host(), path)

  @spec get_filename(String.t()) :: String.t()
  def get_filename(name), do: "QR-" <> String.replace(name, " ", "-")
end
