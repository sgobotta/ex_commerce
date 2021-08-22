defmodule ExCommerceWeb.NavbarView do
  use ExCommerceWeb, :view

  def render("navbar", assigns) do
    opts = Map.put_new(assigns, :exclude_menu, true)

    render("navbar.html", opts)
  end
end
