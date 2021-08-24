defmodule ExCommerceWeb.NavbarView do
  use ExCommerceWeb, :view

  def render("navbar", assigns) do
    opts =
      assigns
      |> Map.put_new(:exclude_menu, true)
      |> Map.put_new(:mode, :topmenu)

    render("navbar.html", opts)
  end

  def render("navbar_link", assigns) do
    opts =
      assigns
      |> Map.put_new(:text, gettext("Link name"))
      |> Map.put_new(:href, "#")
      |> Map.put_new(:on_click, "closeMenu()")

    render("navbar_link.html", opts)
  end

  def render("navbar_link_group", assigns) do
    opts =
      assigns
      |> Map.put_new(:group_name, gettext("Placeholder text"))
      |> Map.put_new(:links, [])

    render("navbar_link_group.html", opts)
  end
end
