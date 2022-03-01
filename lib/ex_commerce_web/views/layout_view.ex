defmodule ExCommerceWeb.LayoutView do
  use ExCommerceWeb, :view

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  alias ExCommerceWeb.Endpoint

  def sidebar_account_dropdown(assigns) do
    ~H"""
    <.dropdown id={@id}>
      <:img src={"https://images.unsplash.com/photo-1610397095767-84a5b4736cbd?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80"}/>
      <:title>User Name</:title>
      <:subtitle>@<%= @current_user.email %></:subtitle>

      <:link href={Routes.user_session_path(Endpoint, :delete)} method={:delete}>Sign out</:link>
    </.dropdown>
    """
  end

  def sidebar_nav_links(assigns) do
    ~H"""
    <div class="space-y-1">
      <%= if @current_user do %>
        <.link
          navigate={Routes.brand_index_path(Endpoint, :index)}
          class={
            "text-gray-700 hover:text-gray-900 group flex items-center
            px-2 py-2
            text-sm font-medium
            rounded-md
            #{if @active_tab == :settings, do: "bg-gray-200", else: "hover:bg-gray-50"}
          "}
          aria-current={if @active_tab == :settings, do: "true", else: "false"}
        >
          <.icon name={:adjustments} outlined class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"/>
          Brands
        </.link>
      <% else %>
        <.link navigate={Routes.user_session_path(Endpoint, :new)}
          class="
            text-gray-700 hover:text-gray-900
            hover:bg-gray-50
            group flex items-center
            px-2 py-2
            text-sm font-medium
            rounded-md
          "
        >
          <svg class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"
            xmlns="http://www.w3.org/2000/svg" fill="none"
            viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          Sign in
        </.link>
      <% end %>
    </div>
    """
  end
end
