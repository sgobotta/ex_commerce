defmodule ExCommerceWeb.Router do
  use ExCommerceWeb, :router

  import ExCommerceWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session

    plug Cldr.Plug.SetLocale,
      apps: [:cldr, :gettext],
      from: [:accept_language, :cookie, :session, :path, :query],
      gettext: ExCommerceWeb.Gettext,
      cldr: ExCommerceWeb.Cldr

    plug :fetch_live_flash
    plug :put_root_layout, {ExCommerceWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ExCommerceWeb do
    pipe_through :browser

    live "/", HomeLive.Index, :index

    live "/places", PlaceLive.Search, :search
    live "/places/:brand", PlaceLive.Index, :index
    live "/places/:brand/:shop", PlaceLive.Show, :show

    scope "/admin" do
      pipe_through [
        :require_authenticated_user,
        :require_confirmed_user
      ]

      live_session :authenticated,
        on_mount: [
          {ExCommerceWeb.UserAuth, :ensure_authenticated},
          {ExCommerceWeb.AdminNav, :default}
        ] do
        live "/", OverviewLive.Index, :index

        # ----------------------------------------------------------------------
        # Brands routes
        #
        scope "/brands" do
          live "/", BrandLive.Index, :index
          live "/new", BrandLive.Index, :new
          live "/:brand_id/edit", BrandLive.Index, :edit
          live "/:brand_id", BrandLive.Show, :show
          live "/:brand_id/show/edit", BrandLive.Show, :edit
        end

        # ----------------------------------------------------------------------
        # Default routes
        #
        live "/shops", ShopLive.Index, :index
        live "/shops/:shop_id", ShopLive.Show, :show

        live "/catalogues", CatalogueLive.Index, :index
        live "/catalogues/:catalogue_id", CatalogueLive.Show, :show

        live "/catalogue_categories", CatalogueCategoryLive.Index, :index

        live "/catalogue_categories/:catalogue_category_id",
             CatalogueCategoryLive.Show,
             :show

        live "/catalogue_items", CatalogueItemLive.Index, :index

        live "/catalogue_items/:catalogue_item_id",
             CatalogueItemLive.Show,
             :show

        live "/catalogue_item_option_groups",
             CatalogueItemOptionGroupLive.Index,
             :index

        live "/catalogue_item_option_groups/:catalogue_item_option_group_id",
             CatalogueItemOptionGroupLive.Show,
             :show

        # ----------------------------------------------------------------------
        # Brand scoped routes
        #
        scope "/:brand_id" do
          # --------------------------------------------------------------------
          # Overview routes
          #
          live "/", OverviewLive.Index, :index

          # --------------------------------------------------------------------
          # Shops routes
          #
          scope "/shops" do
            live "/", ShopLive.Index, :index
            live "/new", ShopLive.Index, :new
            live "/:shop_id/edit", ShopLive.Index, :edit
            live "/:shop_id", ShopLive.Show, :show
            live "/:shop_id/show/edit", ShopLive.Show, :edit
          end

          # --------------------------------------------------------------------
          # Catalogues routes
          #
          scope "/catalogues" do
            live "/", CatalogueLive.Index, :index
            live "/new", CatalogueLive.Index, :new
            live "/:catalogue_id/edit", CatalogueLive.Index, :edit
            live "/:catalogue_id", CatalogueLive.Show, :show
            live "/:catalogue_id/show/edit", CatalogueLive.Show, :edit
          end

          # --------------------------------------------------------------------
          # CatalogueCategories routes
          #
          scope "/catalogue_categories" do
            live "/", CatalogueCategoryLive.Index, :index
            live "/new", CatalogueCategoryLive.Index, :new

            live "/:catalogue_category_id/edit",
                 CatalogueCategoryLive.Index,
                 :edit

            live "/:catalogue_category_id", CatalogueCategoryLive.Show, :show

            live "/:catalogue_category_id/show/edit",
                 CatalogueCategoryLive.Show,
                 :edit
          end

          # --------------------------------------------------------------------
          # CatalogueItems routes
          #
          scope "/catalogue_items" do
            live "/", CatalogueItemLive.Index, :index
            live "/new", CatalogueItemLive.Index, :new
            live "/:catalogue_item_id/edit", CatalogueItemLive.Index, :edit
            live "/:catalogue_item_id", CatalogueItemLive.Show, :show
            live "/:catalogue_item_id/show/edit", CatalogueItemLive.Show, :edit
          end

          # --------------------------------------------------------------------
          # CatalogueItemOptionGroup routes
          #
          scope "/catalogue_item_option_groups" do
            live "/", CatalogueItemOptionGroupLive.Index, :index
            live "/new", CatalogueItemOptionGroupLive.Index, :new

            live "/:catalogue_item_option_group_id/edit",
                 CatalogueItemOptionGroupLive.Index,
                 :edit

            live "/:catalogue_item_option_group_id",
                 CatalogueItemOptionGroupLive.Show,
                 :show

            live "/:catalogue_item_option_group_id/show/edit",
                 CatalogueItemOptionGroupLive.Show,
                 :edit
          end
        end
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExCommerceWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ExCommerceWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", ExCommerceWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", ExCommerceWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update

    get "/users/settings/confirm_email/:token",
        UserSettingsController,
        :confirm_email

    get "/users/settings/confirm_email", UserSettingsController, :email_sent
  end

  scope "/", ExCommerceWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
