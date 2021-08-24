defmodule ExCommerceWeb.LiveHelpers do
  @moduledoc """
  Implements reusable helpers for live views
  """
  import Phoenix.View

  def render_navbar_link(opts) do
    render(ExCommerceWeb.NavbarView, "navbar_link", opts)
  end

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
end
