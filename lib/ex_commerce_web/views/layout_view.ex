defmodule ExCommerceWeb.LayoutView do
  use ExCommerceWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  alias ExCommerceWeb.Endpoint

  import ExCommerceWeb.Gettext

  def sidebar_account_dropdown(assigns) do
    ~H"""
    <.dropdown id={@id}>
      <:img src={"https://images.unsplash.com/photo-1610397095767-84a5b4736cbd?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80"}/>
      <:title><%= gettext("User Name") %></:title>
      <:subtitle><%= @current_user.email %></:subtitle>

      <:link
        href={Routes.user_session_path(Endpoint, :delete)}
        method={:delete}
      ><%= gettext("Sign out") %></:link>

    </.dropdown>
    """
  end

  def main_sidebar_nav_links(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= if @current_user do %>
        <.custom_link
          navigate={Routes.brand_index_path(Endpoint, :index)}
          class={"
            text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
            #{if @active_tab == :brands, do: "bg-gray-200 hover:bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :brands, do: "true", else: "false"}
        >
          <.icon
            name={:building_office_2} outlined
            class="
              flex-shrink-0
              mr-3
              h-6 w-6
              text-gray-400 group-hover:text-gray-500
            "
          />
          <%= gettext("Brands") %>
        </.custom_link>

        <.custom_link
          navigate={Routes.overview_index_path(Endpoint, :index, @brand.id)}
          class={"
            text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
            #{if @active_tab == :overview, do: "bg-gray-200 hover:bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :overview, do: "true", else: "false"}
        >
          <.icon
            name={:home} outlined
            class="
              flex-shrink-0
              mr-3
              h-6 w-6
              text-gray-400 group-hover:text-gray-500
            "
          />
          <%= gettext("Home") %>
        </.custom_link>
        <.custom_link
          navigate={Routes.shop_index_path(Endpoint, :index, @brand.id)}
          class={"
            text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
            #{if @active_tab == :shops, do: "bg-gray-200 hover:bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :shops, do: "true", else: "false"}
        >
          <.icon name={:building_storefront} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
          <%= gettext("Shops") %>
        </.custom_link>
        <.custom_link
          navigate={Routes.catalogue_index_path(Endpoint, :index, @brand.id)}
          class={"
            text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
            #{if @active_tab == :catalogues, do: "bg-gray-200 hover:bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :catalogues, do: "true", else: "false"}
        >
          <.icon name={:book_open} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
          <%= gettext("Catalogues") %>
        </.custom_link>
        <.custom_link
          navigate={Routes.catalogue_category_index_path(Endpoint, :index, @brand.id)}
          class={"
            text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
            #{if @active_tab == :catalogue_categories, do: "bg-gray-200 hover:bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :catalogue_categories, do: "true", else: "false"}
        >
          <.icon name={:bookmark} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
          <%= gettext("Categories") %>
        </.custom_link>
        <.custom_link
          navigate={Routes.catalogue_item_index_path(Endpoint, :index, @brand.id)}
          class={"
            text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
            #{if @active_tab == :catalogue_items, do: "bg-gray-200 hover:bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :catalogue_items, do: "true", else: "false"}
        >
          <.icon name={:swatch} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
          <%= gettext("Items") %>
        </.custom_link>
        <.custom_link
          navigate={Routes.catalogue_item_option_group_index_path(
            Endpoint,
            :index,
            @brand.id
          )}
          class={"
            text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
            #{if @active_tab == :catalogue_item_option_groups, do: "bg-gray-200 hover:bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :catalogue_item_option_groups, do: "true", else: "false"}
        >
          <.icon name={:squares_2x2} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
          <%= gettext("Option Groups") %>
        </.custom_link>
      <% else %>
        <.custom_link navigate={Routes.user_session_path(Endpoint, :new)}
          class="
            text-gray-700 hover:text-gray-900
            hover:bg-gray-50
            group flex items-center
            px-2 py-2
            text-2xl font-medium
            rounded-md
          "
        >
          <svg class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"
            xmlns="http://www.w3.org/2000/svg" fill="none"
            viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <%= gettext("Sign in") %>
        </.custom_link>
      <% end %>
    </div>
    """
  end

  def home_sidebar_nav_links(assigns) do
    ~H"""
    <div class="space-y-1">
      <.custom_link
        class="
          text-gray-700 hover:text-gray-900 group flex items-center
          px-2 py-2
          text-2xl font-medium
          rounded-md
        "
        href="#welcome"
        aria-current="false"
      >
        <.icon name={:home} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
        <%= gettext("Welcome") %>
      </.custom_link>
      <.custom_link
        class="
          text-gray-700 hover:text-gray-900 group flex items-center
          px-2 py-2
          text-2xl font-medium
          rounded-md
        "
        href="#carousel"
        aria-current="false"
      >
        <.icon name={:magnifying_glass} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
        <%= gettext("Search") %>
      </.custom_link>
      <.custom_link
        class="
          text-gray-700 hover:text-gray-900 group flex items-center
          px-2 py-2
          text-2xl font-medium
          rounded-md
        "
        href="#benefits"
        aria-current="false"
      >
        <.icon name={:information_circle} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
        <%= gettext("About") %>
      </.custom_link>
      <.custom_link
        class="
          text-gray-700 hover:text-gray-900 group flex items-center
          px-2 py-2
          text-2xl font-medium
          rounded-md
        "
        href="#plans"
        aria-current="false"
      >
        <.icon name={:lifebuoy} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
        <%= gettext("Support") %>
      </.custom_link>
    </div>
    """
  end
end
