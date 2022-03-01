defmodule ExCommerceWeb.LiveHelpers do
  @moduledoc """
  Implements reusable helpers for live views
  """
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView
  import Phoenix.View

  alias Phoenix.LiveView.JS

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
  # Link helpers
  #

  def render_link(opts) do
    render(ExCommerceWeb.LinksView, "link", opts)
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

  def render_file_input(opts \\ []) do
    render(ExCommerceWeb.ButtonsView, "file_input", opts)
  end

  # ----------------------------------------------------------------------------
  # Select helpers
  #

  def render_select(opts \\ []) do
    render(ExCommerceWeb.SelectsView, "select", opts)
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

  @doc """
  Just a wrapper for `PhoenixInlineSvg.Helpers.svg_image/4`
  """
  @spec render_svg(String.t(), any()) :: {:safe, any}
  def render_svg(path, opts \\ []) do
    PhoenixInlineSvg.Helpers.svg_image(ExCommerceWeb.Endpoint, path, opts)
  end

  # ----------------------------------------------------------------------------
  # Image helpers
  #

  @doc """
  Renders an image.

  ### Options

  * `source`: path to the picture
  * `layout`: one of landscape, portrait or squared

  """
  @spec render_image(keyword) :: {:safe, any}
  def render_image(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "image", opts)
  end

  @doc """
  Renders a small squared image.

  ### Options

  * `source`: path to the picture

  """
  @spec render_thumbnail(keyword) :: {:safe, any}
  def render_thumbnail(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "thumbnail", opts)
  end

  @doc """
  Renders a wide image with fixed dimensions.

  ### Options

  * `source`: path to the picture
  * `container_classes` (Optional): style classes for the div container

  """
  @spec render_banner(keyword()) :: {:safe, any}
  def render_banner(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "banner", opts)
  end

  @doc """
  Renders a preview of an uploaded image with a thumbnail, the name of the file,
  it's size in kb or mb, a progress bar and a delete button.

  ### Options

  * `entry`: a `Phoenix.LiveView.UploadEntry` struct from the
  `@uploads.attr.entries` list.
  * `target`: a `Phoenix.LiveComponent.CID` struct from the live component
  * `cancel_event`: the name of the component's event that cancels the entry.

  """
  @spec render_upload_image_preview(keyword()) :: {:safe, any}
  def render_upload_image_preview(opts \\ []) do
    render(ExCommerceWeb.ImagesView, "upload_image_preview", opts)
  end

  # ----------------------------------------------------------------------------
  # Modal helpers
  #

  @doc """
  Renders a component inside the `ExCommerceWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, ExCommerceWeb.FormComponent,
        id: @shop.id || :new,
        action: @live_action,
        shop: @shop,
        return_to: Routes.shop_index_path(@socket, :index) %>

  """
  def live_modal(_socket, component, opts) do
    return_to_path = Keyword.fetch!(opts, :return_to)
    patch_to_path = Keyword.fetch!(opts, :patch_to)
    redirect_to = Keyword.get(opts, :redirect_to, nil)

    modal_opts = [
      id: :modal,
      return_to: return_to_path,
      patch_to: patch_to_path,
      redirect_to: redirect_to,
      component: component,
      opts: opts
    ]

    live_component(%{
      module: ExCommerceWeb.ModalComponent,
      id: :modal,
      opts: modal_opts
    })
  end

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.public_shop_index_path(@socket, :index)}>
        <.live_component
          module={ExCommerceWeb.PublicShopLive.FormComponent}
          id={@public_shop.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.public_shop_index_path(@socket, :index)}
          public_shop: @public_shop
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch "✖",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          %>
        <% else %>
         <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  # ----------------------------------------------------------------------------
  # Menu revamp helpers
  #

  def connection_status(assigns) do
    ~H"""
    <div
      id="connection-status"
      class="
        hidden
        rounded-md
        bg-red-50
        p-4
        fixed top-1 right-1 w-96
        fade-in-scale
        z-50
      "
      js-show={show("#connection-status")}
      js-hide={hide("#connection-status")}
    >
      <div class="flex">
        <div class="flex-shrink-0">
          <svg
            class="
              animate-spin
              -ml-1 mr-3 h-5 w-5
              text-red-800
            "
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <circle
              class="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              stroke-width="4"
            ></circle>
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z">
            </path>
          </svg>
        </div>
        <div class="ml-3">
          <p
            class="text-sm font-medium text-red-800"
            role="alert"
          >
            <%= render_slot(@inner_block) %>
          </p>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Returns a button triggered dropdown with aria keyboard and focus supporrt.

  Accepts the follow slots:

    * `:id` - The id to uniquely identify this dropdown
    * `:img` - The optional img to show beside the button title
    * `:title` - The button title
    * `:subtitle` - The button subtitle

  ## Examples

      <.dropdown id={@id}>
        <:img src={@current_user.avatar_url}/>
        <:title><%= @current_user.name %></:title>
        <:subtitle>@<%= @current_user.username %></:subtitle>

        <:link navigate={profile_path(@current_user)}>View Profile</:link>
        <:link navigate={Routes.settings_path(LiveBeatsWeb.Endpoint, :edit)}Settings</:link>
      </.dropdown>
  """
  def dropdown(assigns) do
    assigns =
      assigns
      |> assign_new(:img, fn -> nil end)
      |> assign_new(:title, fn -> nil end)
      |> assign_new(:subtitle, fn -> nil end)

    ~H"""
    <!-- User account dropdown -->
    <div class="px-3 mt-6 relative inline-block text-left">
      <div>
        <button
          id={@id}
          type="button"
          class="
            group
            w-full
            rounded-md
            px-3.5 py-2
            text-sm text-left font-medium text-gray-700
            bg-gray-100
            hover:bg-gray-200
            focus:outline-none focus:ring-2 focus:ring-offset-2
            focus:ring-offset-gray-100 focus:ring-purple-500
          "
          phx-click={show_dropdown("##{@id}-dropdown")}
          phx-hook="Menu"
          data-active-class="bg-gray-100"
          aria-haspopup="true"
        >
          <span class="flex w-full justify-between items-center">
            <span class="flex min-w-0 items-center justify-between space-x-3">
              <%= for img <- @img do %>
                <img
                  class="
                    w-10 h-10
                    bg-gray-300
                    rounded-full
                    flex-shrink-0
                  "
                  alt=""
                  {assigns_to_attributes(img)}
                />
              <% end %>
              <span class="flex-1 flex flex-col min-w-0">
                <span class="text-gray-900 text-sm font-medium truncate">
                  <%= render_slot(@title) %>
                </span>
                <span class="text-gray-500 text-sm truncate">
                  <%= render_slot(@subtitle) %>
                </span>
              </span>
            </span>
            <svg class="flex-shrink-0 h-5 w-5 text-gray-400 group-hover:text-gray-500"
              xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"
              fill="currentColor" aria-hidden="true">
              <path fill-rule="evenodd"
                d="M10 3a1 1 0 01.707.293l3 3a1 1 0 01-1.414 1.414L10 5.414 7.707 7.707a1 1 0 01-1.414-1.414l3-3A1 1 0 0110 3zm-3.707 9.293a1 1 0 011.414 0L10 14.586l2.293-2.293a1 1 0 011.414 1.414l-3 3a1 1 0 01-1.414 0l-3-3a1 1 0 010-1.414z"
                clip-rule="evenodd"></path>
            </svg>
          </span>
        </button>
      </div>
      <div
        id={"#{@id}-dropdown"}
        phx-click-away={hide_dropdown("##{@id}-dropdown")}
        class="
          hidden z-10 mx-3 origin-top
          absolute right-0 left-0
          mt-1
          rounded-md
          shadow-lg
          bg-white
          ring-1 ring-black ring-opacity-5
          divide-y divide-gray-200
        "
        role="menu"
        aria-labelledby={@id}
      >
        <div class="py-1" role="none">
          <%= for link <- @link do %>
            <.link
              tabindex="-1"
              role="menuitem"
              class="
                block
                px-4 py-2
                text-sm text-gray-700
                hover:bg-gray-100
                focus:outline-none focus:ring-2 focus:ring-offset-2
                focus:ring-offset-gray-100 focus:ring-purple-500
              "
              {link}
            ><%= render_slot(link) %></.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def show_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.show(to: "#mobile-sidebar-container", transition: "fade-in")
    |> JS.show(
      to: "#mobile-sidebar",
      display: "flex",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "-translate-x-full",
         "translate-x-0"}
    )
    |> JS.hide(to: "#show-mobile-sidebar", transition: "fade-out")
    |> JS.dispatch("js:exec",
      to: "#hide-mobile-sidebar",
      detail: %{call: "focus", args: []}
    )
  end

  def hide_mobile_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(to: "#mobile-sidebar-container", transition: "fade-out")
    |> JS.hide(
      to: "#mobile-sidebar",
      time: 300,
      transition:
        {"transition ease-in-out duration-300 transform", "translate-x-0",
         "-translate-x-full"}
    )
    |> JS.show(to: "#show-mobile-sidebar", transition: "fade-in")
    |> JS.dispatch("js:exec",
      to: "#show-mobile-sidebar",
      detail: %{call: "focus", args: []}
    )
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      display: "inline-block",
      transition:
        {"ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 300,
      transition:
        {"transition ease-in duration-300", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
  end

  def show_dropdown(to) do
    JS.show(
      to: to,
      transition:
        {"transition ease-out duration-120", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
    |> JS.set_attribute({"aria-expanded", "true"}, to: to)
  end

  def hide_dropdown(to) do
    JS.hide(
      to: to,
      transition:
        {"transition ease-in duration-120", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
    |> JS.remove_attribute("aria-expanded", to: to)
  end

  def link(%{navigate: _to} = assigns) do
    assigns = assign_new(assigns, :class, fn -> nil end)

    ~H"""
    <a
      href={@navigate}
      data-phx-link="redirect"
      data-phx-link-state="push"
      class={@class}
    >
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  def link(%{patch: to} = assigns) do
    opts = assigns |> assigns_to_attributes() |> Keyword.put(:to, to)
    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= live_patch @opts do %><%= render_slot(@inner_block) %><% end %>
    """
  end

  def link(%{} = assigns) do
    opts =
      assigns
      |> assigns_to_attributes()
      |> Keyword.put(:to, assigns[:href] || "#")

    assigns = assign(assigns, :opts, opts)

    ~H"""
    <%= Phoenix.HTML.Link.link @opts do %><%= render_slot(@inner_block) %><% end %>
    """
  end

  def icon(assigns) do
    assigns =
      assigns
      |> assign_new(:outlined, fn -> false end)
      |> assign_new(:class, fn -> "w-4 h-4 inline-block" end)
      |> assign_new(:"aria-hidden", fn ->
        !Map.has_key?(assigns, :"aria-label")
      end)

    ~H"""
    <%= if @outlined do %>
      <%= apply(Heroicons.Outline, @name, [assigns_to_attributes(assigns, [:outlined, :name])]) %>
    <% else %>
      <%= apply(Heroicons.Solid, @name, [assigns_to_attributes(assigns, [:outlined, :name])]) %>
    <% end %>
    """
  end

  def flash(%{kind: :error} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-red-50 p-4 fixed top-1 right-1 w-96 fade-in-scale z-50"
        phx-click={JS.push("lv:clear-flash") |> JS.remove_class("fade-in-scale", to: "#flash") |> hide("#flash")}
        phx-hook="Flash"
      >
        <div class="flex justify-between items-center space-x-3 text-red-700">
          <.icon name={:exclamation_circle} class="w-5 w-5"/>
          <p class="flex-1 text-sm font-medium" role="alert">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button type="button" class="inline-flex bg-red-50 rounded-md p-1.5 text-red-500 hover:bg-red-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-red-50 focus:ring-red-600">
            <.icon name={:x} class="w-4 h-4" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  def flash(%{kind: :info} = assigns) do
    ~H"""
    <%= if live_flash(@flash, @kind) do %>
      <div
        id="flash"
        class="rounded-md bg-green-50 p-4 fixed top-1 right-1 w-96 fade-in-scale z-50"
        phx-click={JS.push("lv:clear-flash") |> JS.remove_class("fade-in-scale") |> hide("#flash")}
        phx-value-key="info"
        phx-hook="Flash"
      >
        <div class="flex justify-between items-center space-x-3 text-green-700">
          <.icon name={:check_circle} class="w-5 h-5"/>
          <p class="flex-1 text-sm font-medium" role="alert">
            <%= live_flash(@flash, @kind) %>
          </p>
          <button
            type="button"
            class="
              inline-flex
              rounded-md p-1.5
              text-green-500
              bg-green-50
              hover:bg-green-100
              focus:outline-none focus:ring-2 focus:ring-offset-2
              focus:ring-offset-green-50 focus:ring-green-600
            "
          >
            <.icon name={:x} class="w-4 h-4" />
          </button>
        </div>
      </div>
    <% end %>
    """
  end
end
