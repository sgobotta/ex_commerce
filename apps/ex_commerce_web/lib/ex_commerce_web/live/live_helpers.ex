defmodule ExCommerceWeb.LiveHelpers do
  @moduledoc """
  Implements reusable helpers for live views
  """
  import Phoenix.LiveView.Helpers
  import Phoenix.View

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

  @spec render_svg(String.t(), any()) :: {:safe, any}
  def render_svg(path, opts \\ []) do
    PhoenixInlineSvg.Helpers.svg_image(ExCommerceWeb.Endpoint, path, opts)
  end

  # ----------------------------------------------------------------------------
  # Select helpers
  #

  def render_thumbnail(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "thumbnail", opts)
  end

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
end
