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

    scope "/admin" do
      pipe_through [
        :require_authenticated_user,
        :require_confirmed_user
      ]

      live "/", HomeLive.Index, :index

      # ------------------------------------------------------------------------
      # Brands routes

      live "/brands", BrandLive.Index, :index
      live "/brands/new", BrandLive.Index, :new
      live "/brands/:brand_id/edit", BrandLive.Index, :edit

      live "/brands/:brand_id", BrandLive.Show, :show
      live "/brands/:brand_id/show/edit", BrandLive.Show, :edit

      # ------------------------------------------------------------------------
      # Default routes
      live "/shops", ShopLive.Index, :index
      live "/shops/:shop_id", ShopLive.Show, :show

      live "/catalogues", CatalogueLive.Index, :index
      live "/catalogues/:catalogue_id", CatalogueLive.Show, :show

      live "/catalogue_categories", CatalogueCategoryLive.Index, :index

      live "/catalogue_categories/:catalogue_category_id",
           CatalogueCategoryLive.Show,
           :show

      scope "/:brand_id" do
        live "/", HomeLive.Index, :index

        # ----------------------------------------------------------------------
        # Shops routes

        live "/shops", ShopLive.Index, :index
        live "/shops/new", ShopLive.Index, :new
        live "/shops/:shop_id/edit", ShopLive.Index, :edit

        live "/shops/:shop_id", ShopLive.Show, :show
        live "/shops/:shop_id/show/edit", ShopLive.Show, :edit

        # ======================================================================
        # Offerings routes

        # ----------------------------------------------------------------------
        # Catalogues routes

        live "/catalogues", CatalogueLive.Index, :index
        live "/catalogues/new", CatalogueLive.Index, :new
        live "/catalogues/:catalogue_id/edit", CatalogueLive.Index, :edit

        live "/catalogues/:catalogue_id", CatalogueLive.Show, :show
        live "/catalogues/:catalogue_id/show/edit", CatalogueLive.Show, :edit

        # ----------------------------------------------------------------------
        # CatalogueCategories routes

        live "/catalogue_categories", CatalogueCategoryLive.Index, :index
        live "/catalogue_categories/new", CatalogueCategoryLive.Index, :new

        live "/catalogue_categories/:catalogue_category_id/edit",
             CatalogueCategoryLive.Index,
             :edit

        live "/catalogue_categories/:catalogue_category_id",
             CatalogueCategoryLive.Show,
             :show

        live "/catalogue_categories/:catalogue_category_id/show/edit",
             CatalogueCategoryLive.Show,
             :edit
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

    get "/", WebController, :index

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
