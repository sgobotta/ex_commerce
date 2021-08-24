defmodule ExCommerceWeb.LiveHelpers do
  @moduledoc """
  Implements reusable helpers for live views
  """
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
  # Button helpers
  #

  def render_logout_button(opts) do
    render(ExCommerceWeb.ButtonsView, "logout_button", opts)
  end

  def render_image_button(opts \\ []) do
    render(ExCommerceWeb.ButtonsView, "image_button", opts)
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
end
