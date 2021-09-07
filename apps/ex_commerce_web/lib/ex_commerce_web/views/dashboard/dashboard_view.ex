defmodule ExCommerceWeb.DashboardView do
  use ExCommerceWeb, :view

  import Phoenix.View

  def render("dashboard", assigns) do
    navbar_opts =
      assigns
      |> Map.put_new(:current_page, "home")

    render_layout(
      ExCommerceWeb.NavbarView,
      "navbar",
      [
        mode: :sidemenu,
        exclude_menu: false,
        header_buttons: [
          render_logout_button(classes: "capitalize")
        ],
        links: [
          navbar_link_group(
            [
              children: ["home"],
              group_name: "Home",
              links: [
                navbar_link(
                  [
                    name: "home",
                    text: gettext("Home"),
                    to:
                      Routes.admin_dashboard_path(
                        ExCommerceWeb.Endpoint,
                        :index
                      )
                  ],
                  navbar_opts
                )
              ]
            ],
            navbar_opts
          ),
          navbar_link_group(
            [
              children: ["shops", "inventory"],
              group_name: "Shops",
              links: [
                navbar_link(
                  [
                    name: "shops",
                    text: gettext("Shops"),
                    to: Routes.shop_index_path(ExCommerceWeb.Endpoint, :index)
                  ],
                  navbar_opts
                ),
                navbar_link(
                  [
                    name: "inventory",
                    text: gettext("Inventory/Menu"),
                    to: "#inventory"
                  ],
                  navbar_opts
                )
              ]
            ],
            navbar_opts
          )
        ],
        logo: render_image_button(text: "Ex Commerce"),
        current_page: navbar_opts.current_page
      ],
      do: assigns.inner_content
    )
  end

  defp navbar_link(default_opts, opts) do
    current_page = Map.fetch!(opts, :current_page)

    opts =
      default_opts
      |> Keyword.merge(current_page: current_page)

    render_navbar_link(opts)
  end

  defp navbar_link_group(default_opts, opts) do
    current_page = Map.fetch!(opts, :current_page)

    opts =
      default_opts
      |> Keyword.merge(current_page: current_page)

    render_navbar_link_group(opts)
  end
end
