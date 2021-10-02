defmodule ExCommerceWeb.DashboardView do
  use ExCommerceWeb, :view

  import Phoenix.View

  alias ExCommerce.Marketplaces.Brand

  def render("brands", assigns) do
    %{user_email: user_email} = assigns

    render_layout(
      ExCommerceWeb.NavbarView,
      "navbar",
      [
        mode: :topmenu,
        exclude_menu: false,
        header_buttons: [
          render_select(
            use_icon: true,
            icon:
              img_tag(
                "https://images.unsplash.com/photo-1610397095767-84a5b4736cbd?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                class: "w-full h-full object-cover",
                alt: "Menu"
              ),
            text: user_email,
            links: []
          ),
          render_logout_button(classes: "capitalize")
        ],
        links: [],
        logo: render_image_button(text: "Ex Commerce")
      ],
      do: assigns.inner_content
    )
  end

  def render("dashboard", assigns) do
    %{user_email: user_email, brand: %Brand{id: brand_id}} = assigns

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
          render_select(
            use_icon: true,
            icon:
              img_tag(
                "https://images.unsplash.com/photo-1610397095767-84a5b4736cbd?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
                class: "w-full h-full object-cover",
                alt: "Menu"
              ),
            text: user_email,
            links: [
              render_link(
                text: "Brands",
                name: "brands",
                to: Routes.brand_index_path(ExCommerceWeb.Endpoint, :index)
              )
            ]
          ),
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
                      Routes.home_index_path(
                        ExCommerceWeb.Endpoint,
                        :index,
                        brand_id
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
              children: ["shops", "brands"],
              group_name: gettext("Marketplaces"),
              links: [
                navbar_link(
                  [
                    name: "shops",
                    text: gettext("Shops"),
                    to:
                      Routes.shop_index_path(
                        ExCommerceWeb.Endpoint,
                        :index,
                        brand_id
                      )
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
