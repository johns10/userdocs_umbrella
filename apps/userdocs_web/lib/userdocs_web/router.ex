defmodule UserDocsWeb.Router do
  use UserDocsWeb, :router

  import UserDocsWeb.UserAuth
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug UserDocsWeb.TestPlug
    plug :fetch_live_flash
    plug :put_root_layout, {UserDocsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  scope "/" do
    pipe_through :browser
    pow_routes()
  end

  scope "/", UserDocsWeb do
    # pipe_through [:browser, :protected]
    pipe_through [:browser]

    live "/", PageLive, :index
    live "/automation", AutomationLive.Index, :index
    live "/process_administrator", ProcessAdministratorLive.Index, :index
    live "/document", DocumentLive.Index, :index
    live "/index.html", ProcessAdministratorLive.Index, :index

    live "/content", ContentLive.Index, :index
    live "/content/new", ContentLive.Index, :new
    live "/content/:id/edit", ContentLive.Index, :edit
    live "/content/:id", ContentLive.Show, :show
    live "/content/:id/show/edit", ContentLive.Show, :edit
    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit
    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit
    live "/teams", TeamLive.Index, :index
    live "/teams/new", TeamLive.Index, :new
    live "/teams/:id/edit", TeamLive.Index, :edit
    live "/teams/:id", TeamLive.Show, :show
    live "/teams/:id/show/edit", TeamLive.Show, :edit
    live "/team_users", TeamUserLive.Index, :index
    live "/team_users/new", TeamUserLive.Index, :new
    live "/team_users/:id/edit", TeamUserLive.Index, :edit
    live "/team_users/:id", TeamUserLive.Show, :show
    live "/team_users/:id/show/edit", TeamUserLive.Show, :edit
    live "/projects", ProjectLive.Index, :index
    live "/projects/new", ProjectLive.Index, :new
    live "/projects/:id/edit", ProjectLive.Index, :edit
    live "/projects/:id", ProjectLive.Show, :show
    live "/projects/:id/show/edit", ProjectLive.Show, :edit
    live "/versions", VersionLive.Index, :index
    live "/versions/new", VersionLive.Index, :new
    live "/versions/:id/edit", VersionLive.Index, :edit
    live "/versions/:id", VersionLive.Show, :show
    live "/versions/:id/show/edit", VersionLive.Show, :edit
    live "/pages", PageLive.Index, :index
    live "/pages/new", PageLive.Index, :new
    live "/pages/:id/edit", PageLive.Index, :edit
    live "/pages/:id", PageLive.Show, :show
    live "/pages/:id/show/edit", PageLive.Show, :edit
    live "/annotation_types", AnnotationTypeLive.Index, :index
    live "/annotation_types/new", AnnotationTypeLive.Index, :new
    live "/annotation_types/:id/edit", AnnotationTypeLive.Index, :edit
    live "/annotation_types/:id", AnnotationTypeLive.Show, :show
    live "/annotation_types/:id/show/edit", AnnotationTypeLive.Show, :edit
    live "/elements", ElementLive.Index, :index
    live "/elements/new", ElementLive.Index, :new
    live "/elements/:id/edit", ElementLive.Index, :edit
    live "/elements/:id", ElementLive.Show, :show
    live "/elements/:id/show/edit", ElementLive.Show, :edit
    live "/annotations", AnnotationLive.Index, :index
    live "/annotations/new", AnnotationLive.Index, :new
    live "/annotations/:id/edit", AnnotationLive.Index, :edit
    live "/annotations/:id", AnnotationLive.Show, :show
    live "/annotations/:id/show/edit", AnnotationLive.Show, :edit
    live "/step_types", StepTypeLive.Index, :index
    live "/step_types/new", StepTypeLive.Index, :new
    live "/step_types/:id/edit", StepTypeLive.Index, :edit
    live "/step_types/:id", StepTypeLive.Show, :show
    live "/step_types/:id/show/edit", StepTypeLive.Show, :edit
    live "/steps", StepLive.Index, :index
    live "/steps/new", StepLive.Index, :new
    live "/steps/:id/edit", StepLive.Index, :edit
    live "/steps/:id", StepLive.Show, :show
    live "/steps/:id/show/edit", StepLive.Show, :edit
    live "/jobs", JobLive.Index, :index
    live "/jobs/new", JobLive.Index, :new
    live "/jobs/:id/edit", JobLive.Index, :edit
    live "/jobs/:id", JobLive.Show, :show
    live "/jobs/:id/show/edit", JobLive.Show, :edit
    live "/processes", ProcessLive.Index, :index
    live "/processes/new", ProcessLive.Index, :new
    live "/processes/:id/edit", ProcessLive.Index, :edit
    live "/processes/:id", ProcessLive.Show, :show
    live "/processes/:id/show/edit", ProcessLive.Show, :edit

    live "/files", FileLive.Index, :index
    live "/files/new", FileLive.Index, :new
    live "/files/:id/edit", FileLive.Index, :edit
    live "/files/:id", FileLive.Show, :show
    live "/files/:id/show/edit", FileLive.Show, :edit

    live "/screenshots", ScreenshotLive.Index, :index
    live "/screenshots/new", ScreenshotLive.Index, :new
    live "/screenshots/:id/edit", ScreenshotLive.Index, :edit
    live "/screenshots/:id", ScreenshotLive.Show, :show
    live "/screenshots/:id/show/edit", ScreenshotLive.Show, :edit

    live "/documents", DocumentLive.Index, :index
    live "/documents/new", DocumentLive.Index, :new
    live "/documents/:id/edit", DocumentLive.Index, :edit
    live "/documents/:id", DocumentLive.Show, :show
    live "/documents/:id/show/edit", DocumentLive.Show, :edit

    live "/documents/:id/editor", DocumentLive.Editor, :edit

    live "/content_versions", ContentVersionLive.Index, :index
    live "/content_versions/new", ContentVersionLive.Index, :new
    live "/content_versions/:id/edit", ContentVersionLive.Index, :edit
    live "/content_versions/:id", ContentVersionLive.Show, :show
    live "/content_versions/:id/show/edit", ContentVersionLive.Show, :edit

    live "/language_codes", LanguageCodeLive.Index, :index
    live "/language_codes/new", LanguageCodeLive.Index, :new
    live "/language_codes/:id/edit", LanguageCodeLive.Index, :edit
    live "/language_codes/:id", LanguageCodeLive.Show, :show
    live "/language_codes/:id/show/edit", LanguageCodeLive.Show, :edit

  end

  # Other scopes may use custom stacks.
  # scope "/api", UserDocsWeb do
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
      pipe_through [:browser, :protected]
      pow_routes()
      live_dashboard "/dashboard", metrics: UserDocsWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", UserDocsWeb do
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

  scope "/", UserDocsWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings/update_password", UserSettingsController, :update_password
    put "/users/settings/update_email", UserSettingsController, :update_email
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", UserDocsWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
