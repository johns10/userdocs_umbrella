defmodule UserDocsWeb.Router do
  use UserDocsWeb, :router

  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :root_layout
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  def root_layout(conn, _opts) do
    case get_req_header(conn, "app") do
      [ "chrome-extension" ] ->
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
      error_handler: UserDocsWeb.AuthErrorHandler
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: UserDocsWeb.AuthErrorHandler
  end

  scope "/", UserDocsWeb do
    pipe_through [:browser, :not_authenticated]

    get "/session", SessionController, :new, as: :login
    post "/session", SessionController, :create, as: :login
  end

  scope "/", UserDocsWeb do
    pipe_through [:browser, :protected]

    delete "/session", SessionController, :delete, as: :logout
  end

  scope "/", UserDocsWeb do
    pipe_through :browser

    live "/documents", DocumentLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/process_administrator", ProcessAdministratorLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/documents/:id/editor", DocumentLive.Editor, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
    live "/documents/:id/viewer", DocumentLive.Viewer, :edit, session: {UserDocsWeb.LiveHelpers, :which_app, []}
  end

  scope "/", UserDocsWeb do
    #pipe_through [:protected]
    pipe_through [ :browser, :protected ]

    live "/", PageLive, :index

    live "/index.html", ProcessAdministratorLive.Index, :index, session: {UserDocsWeb.LiveHelpers, :which_app, []}

    get "/document_versions/:id/download", DocumentVersionDownloadController, :show

    live "/content", ContentLive.Index, :index
    live "/content/new", ContentLive.Index, :new
    live "/content/:id/edit", ContentLive.Index, :edit
    live "/content/:id", ContentLive.Show, :show
    live "/content/:id/show/edit", ContentLive.Show, :edit

    live "/teams", TeamLive.Index, :index
    live "/teams/new", TeamLive.Index, :new
    live "/teams/:id/edit", TeamLive.Index, :edit
    live "/teams/:id", TeamLive.Show, :show
    live "/teams/:id/show/edit", TeamLive.Show, :edit

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit
    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit


  end

  _commented_code = """
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
