defmodule ExCommerceWeb.NavbarView do
  use ExCommerceWeb, :view

  def render("navbar", assigns) do
    opts =
      assigns
      |> Map.put_new(:exclude_menu, true)
      |> Map.put_new(:mode, :topmenu)

    render("navbar.html", opts)
  end
end
