defmodule UserDocsWeb.Router do
  use UserDocsWeb, :router
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :root_layout
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  def root_layout(conn, _opts) do
    case conn.host do
      "dev-electron-app.user-docs.com" ->
        conn
        |> put_root_layout({UserDocsWeb.LayoutView, :root})
        |> assign(:app_name, :electron)
      "electron-app.user-docs.com" ->
        conn
        |> put_root_layout({UserDocsWeb.LayoutView, :root})
        |> assign(:app_name, :electron)
      "extension.user-docs.com" ->
        conn
        |> put_root_layout({UserDocsWeb.LayoutView, :chrome_root})
        |> assign(:app_name, :chrome)
      _ ->
        conn
        |> put_root_layout({UserDocsWeb.LayoutView, :root})
        |> assign(:app_name, :web)
    end
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: Pow.Plug.RequireNotAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug UserDocsWeb.API.Auth.Plug, otp_app: :userdocs_web
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: UserDocsWeb.API.Auth.ErrorHandler
    plug UserDocsWeb.API.Auth.Context
  end

  scope "/api", UserDocsWeb.API, as: :api do
    pipe_through :api


    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew
  end

  if Mix.env() in [:dev, :test] do
    scope "/api", as: :api do
      pipe_through :api

      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: UserDocsWeb.API.Schema

    end
  end

  scope "/api", as: :api do
    #pipe_through :api
    pipe_through [:api, :api_protected]

    forward "/", Absinthe.Plug,
      schema: UserDocsWeb.API.Schema

  end

  scope "/", UserDocsWeb do
    pipe_through [:browser, :protected]

    live "/", PageLive, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    live "/users/new", UserLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/users", UserLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/users/:id", UserLive.Show, :show, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/users/:id/show/edit", UserLive.Show, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/users/:id/show/options", UserLive.Show, :options, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/users/:id/edit", UserLive.Index, :edit

    live "/teams/new", TeamLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/teams", TeamLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/teams/:id", TeamLive.Show, :show, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/teams/:id/edit", TeamLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    live "/teams/:team_id/projects", ProjectLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/projects", ProjectLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/projects/:id/edit", ProjectLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/projects/new", ProjectLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/projects/:id", ProjectLive.Show, :show, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    live "/projects/:project_id/versions", VersionLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/versions", VersionLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/versions/new", VersionLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/versions/:id", VersionLive.Show, :show, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/versions/:id/edit", VersionLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    live "/versions/:version_id/processes", ProcessLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/processes", ProcessLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/processes/new", ProcessLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/processes/:id", ProcessLive.Show, :show, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/processes/:id/edit", ProcessLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    live "/processes/:process_id/steps", StepLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/processes/:process_id/steps/new", StepLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/steps/:id/edit", StepLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/steps/:id/screenshot", StepLive.Index, :screenshot_workflow, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    live "/content", ContentLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/teams/:team_id/content", ContentLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/content/new", ContentLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/teams/:team_id/content/new", ContentLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/content/:id/edit", ContentLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/teams/:team_id/content/:id/edit", ContentLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/content/:id", ContentLive.Show, :show, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/teams/:team_id/content/:id", ContentLive.Show, :show, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    live "/projects/:project_id/documents", DocumentLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/documents/new", DocumentLive.Index, :new, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/documents", DocumentLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/documents/:id/edit", DocumentLive.Index, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/documents/:id/editor", DocumentLive.Editor, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/documents/:id/viewer", DocumentLive.Viewer, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    get "/document_versions/:id/download", DocumentVersionDownloadController, :show

    live "/content/:id/show/edit", ContentLive.Show, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
  end

  scope "/", UserDocsWeb do
    pipe_through [:browser, :not_authenticated, :put_user_agent_data]

    live "/signup", SignupLive.Index, :new
    live "/setup", SignupLive.Index, :setup
  end

  def put_user_agent_data(conn, _opts) do
    ua = get_req_header(conn, "user-agent")
    ua =
      case ua do
        [ ua | _ ] -> ua
        [] -> "Mozilla/5.0 (Linux; Android 7.0; SM-G930VC Build/NRD90M; wv)"
      end

    conn
    |> put_session(:os, UAInspector.parse(ua).os.name)
  end

  scope "/" do
    pipe_through :browser
    pow_routes()
    pow_extension_routes()
  end


  _commented_code = """

  scope "/", UserDocsWeb do
    pipe_through [:browser, :protected]

    delete "/session", SessionController, :delete, as: :logout
  end

  scope "/", UserDocsWeb do
    #pipe_through [:protected]
    pipe_through [ :browser, :protected ]

    live "/process_administrator", ProcessAdministratorLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}




  end

  scope "/", UserDocsWeb do
    pipe_through [:browser, :protected]

    delete "/session", SessionController, :delete, as: :logout
  end

  scope "/" do
    pipe_through :browser
    pow_routes()
  end

  scope "/" do
    pipe_through :browser
    get "/session/new", Pow.Phoenix.SessionController, :new
    get "/registration/edit", Pow.Phoenix.RegistrationController, :edit
    get "/registration/new", Pow.Phoenix.RegistrationController, :new
    post "/registration", Pow.Phoenix.RegistrationController, :create
    patch "/registration", Pow.Phoenix.RegistrationController, :update
    put "/registration", Pow.Phoenix.RegistrationController, :update
    delete "/registration", Pow.Phoenix.RegistrationController, :delete
  end
"""

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

    forward "/sent_emails", Bamboo.SentEmailViewerPlug

    scope "/" do
      pipe_through :browser
      pow_routes()
    end

    scope "/" do
      pipe_through [:browser, :protected]
      live_dashboard "/dashboard", metrics: UserDocsWeb.Telemetry
    end
  end

end
