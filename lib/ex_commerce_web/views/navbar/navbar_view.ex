defmodule ExCommerceWeb.NavbarView do
  use ExCommerceWeb, :view

  def render("navbar", assigns) do
    opts =
      assigns
      |> Map.put_new(:exclude_menu, true)
      |> Map.put_new(:mode, :topmenu)

    render("navbar.html", opts)
  end

  @default_navbar_link_classes "m-nv-link text-white-FIXME bg-purple-500-FIXME"

  def render("navbar_link", assigns) do
    opts =
      assigns
      |> Map.put_new(:name, "unknown-name")
      |> Map.put_new(:text, gettext("Link name"))
      |> Map.put_new(:to, "#")
      |> Map.put_new(:onclick, "closeMenu()")
      |> assign_classes()
      |> assign_link_props_maybe()

    render("navbar_link.html", opts)
  end

  def render("navbar_link_group", assigns) do
    opts =
      assigns
      |> assign_classes()
      |> Map.put_new(:group_name, gettext("Placeholder text"))
      |> Map.put_new(:links, [])

    render("navbar_link_group.html", opts)
  end

  defp assign_classes(%{name: name, current_page: current_page} = assigns) do
    class =
      if name == current_page do
        "m-nv-link-active"
      else
        ""
      end

    Map.put_new(assigns, :class, "#{@default_navbar_link_classes} #{class}")
  end

  defp assign_classes(
         %{children: children, current_page: current_page} = assigns
       ) do
    class =
      if current_page in children do
        "nv-link-group-active"
      else
        ""
      end

    Map.put_new(assigns, :class, "#{@default_navbar_link_classes} #{class}")
  end

  defp assign_classes(assigns), do: assigns

  defp assign_link_props_maybe(assigns) do
    link_props = [:to, :class, :onclick]

    {_assigns, opts} =
      Enum.reduce(link_props, {assigns, Map.new()}, fn opt, {opts, acc} ->
        case Map.has_key?(opts, opt) do
          true ->
            {opts, Map.put_new(acc, opt, Map.get(opts, opt))}

          false ->
            {opts, acc}
        end
      end)

    Map.put_new(assigns, :link_props, opts)
  end
end
