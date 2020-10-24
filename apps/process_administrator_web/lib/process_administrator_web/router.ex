defmodule ProcessAdministratorWeb.Router do
  use ProcessAdministratorWeb, :router

  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ProcessAdministratorWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: ProcessAdministratorWeb.AuthErrorHandler
  end

  scope "/", ProcessAdministratorWeb do
    pipe_through [:browser, :not_authenticated]

    get "/session", SessionController, :new, as: :login
    post "/session", SessionController, :create, as: :login
  end

  scope "/", ProcessAdministratorWeb do
    pipe_through :browser

    live "/", IndexLive, :index
    live "index.html", ProcessAdministratorLive.Index, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ProcessAdministratorWeb do
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
      live_dashboard "/dashboard", metrics: ProcessAdministratorWeb.Telemetry
    end
  end
end
