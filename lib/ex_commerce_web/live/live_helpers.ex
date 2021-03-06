defmodule ExCommerceWeb.LiveHelpers do
  @moduledoc """
  Implements reusable helpers for live views
  """
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView
  import Phoenix.View

  alias Phoenix.LiveView.JS

  # ----------------------------------------------------------------------------
  # Navbar helpers
  #

  def render_navbar_link(opts) do
    render(ExCommerceWeb.NavbarView, "navbar_link", opts)
  end

  def render_navbar_link_group(opts) do
    render(ExCommerceWeb.NavbarView, "navbar_link_group", opts)
  end

  # ----------------------------------------------------------------------------
  # Link helpers
  #

  def render_link(opts) do
    render(ExCommerceWeb.LinksView, "link", opts)
  end

  # ----------------------------------------------------------------------------
  # Button helpers
  #

  def render_logout_button(opts) do
    render(ExCommerceWeb.ButtonsView, "logout_button", opts)
  end

  def render_image_button(opts \\ []) do
    render(ExCommerceWeb.ButtonsView, "image_button", opts)
  end

  def render_file_input(opts \\ []) do
    render(ExCommerceWeb.ButtonsView, "file_input", opts)
  end

  # ----------------------------------------------------------------------------
  # Select helpers
  #

  def render_select(opts \\ []) do
    render(ExCommerceWeb.SelectsView, "select", opts)
  end

  # ----------------------------------------------------------------------------
  # Data display helpers
  #

  @doc """
  Given some options renders a tooltip component.

  > The parent component must use the tailwind class `group` to bind events to
  > the child tooltip.

  ## Examples

      <%= ExCommerceWeb.LiveHelpers.render_tooltip(text: "Some awesome message") %>

      <%= ExCommerceWeb.LiveHelpers.render_tooltip(
        text: "Another awesome message"),
        extra_classes: "text-lg text-red-800"
      %>

      iex> ExCommerceWeb.LiveHelpers.render_tooltip(text: "Some awesome message")
      {:safe, ["<div class="...">...</div>", [], "", ""]}

  """
  @spec render_tooltip(keyword) :: any
  def render_tooltip(opts \\ []) do
    render(ExCommerceWeb.DataDisplayView, "tooltip", opts)
  end

  # ----------------------------------------------------------------------------
  # Svg helpers
  #

  @doc """
  Just a wrapper for `PhoenixInlineSvg.Helpers.svg_image/4`
  """
  @spec render_svg(String.t(), any()) :: {:safe, any}
  def render_svg(path, opts \\ []) do
    PhoenixInlineSvg.Helpers.svg_image(ExCommerceWeb.Endpoint, path, opts)
  end

  # ----------------------------------------------------------------------------
  # Select helpers
  #

  @doc """
  Renders a squared image.

  ### Options

  * `source`: path to the picture
  * `size`: a valid tailwind height/width value without the h- or w-
  * `container_classes` (Optional): style classes for the div container

  """
  @spec render_thumbnail(keyword) :: {:safe, any}
  def render_thumbnail(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "thumbnail", opts)
  end

  @doc """
  Renders a wide image with fixed dimensions.

  ### Options

  * `source`: path to the picture
  * `container_classes` (Optional): style classes for the div container

  """
  @spec render_banner(keyword()) :: {:safe, any}
  def render_banner(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "banner", opts)
  end

  @doc """
  Renders a preview of an uploaded image with a thumbnail, the name of the file,
  it's size in kb or mb, a progress bar and a delete button.

  ### Options

  * `entry`: a `Phoenix.LiveView.UploadEntry` struct from the
  `@uploads.attr.entries` list.
  * `target`: a `Phoenix.LiveComponent.CID` struct from the live component
  * `cancel_event`: the name of the component's event that cancels the entry.

  """
  @spec render_upload_image_preview(keyword()) :: {:safe, any}
  def render_upload_image_preview(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "upload_image_preview", opts)
  end

  # ----------------------------------------------------------------------------
  # Modal helpers
  #

  @doc """
  Renders a component inside the `ExCommerceWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, ExCommerceWeb.FormComponent,
        id: @shop.id || :new,
        action: @live_action,
        shop: @shop,
        return_to: Routes.shop_index_path(@socket, :index) %>

  """
  def live_modal(_socket, component, opts) do
    return_to_path = Keyword.fetch!(opts, :return_to)
    patch_to_path = Keyword.fetch!(opts, :patch_to)
    redirect_to = Keyword.get(opts, :redirect_to, nil)

    modal_opts = [
      id: :modal,
      return_to: return_to_path,
      patch_to: patch_to_path,
      redirect_to: redirect_to,
      component: component,
      opts: opts
    ]

    live_component(%{
      module: ExCommerceWeb.ModalComponent,
      id: :modal,
      opts: modal_opts
    })
  end

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.public_shop_index_path(@socket, :index)}>
        <.live_component
          module={ExCommerceWeb.PublicShopLive.FormComponent}
          id={@public_shop.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.public_shop_index_path(@socket, :index)}
          public_shop: @public_shop
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch "???",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          %>
        <% else %>
         <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>???</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end
