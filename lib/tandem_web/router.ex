defmodule TandemWeb.Router do
  use TandemWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TandemWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug TandemWeb.Plugs.SetUser
  end

  pipeline :session do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TandemWeb.Layouts, :login}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :no_layout do
    plug :put_layout, false
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # ------------- NO LAYOUT SCOPE
  scope "/", TandemWeb do
    pipe_through([:browser, :no_layout])
    get("/signout", SessionController, :signout)
  end

  # ------------- SESSION SCOPE
  scope "/", TandemWeb do
    pipe_through :session
    get "/", SessionController, :login
    post "/login", SessionController, :create
  end

  scope "/", TandemWeb do
    pipe_through :browser

    get "/applicant/dashboard", PageController, :applicant
    post "/save/draft", PageController, :save_draft
    post "/membership/application", PageController, :membership_application
    get "/approver/dashboard", PageController, :approver
    get "/membership/application/details/:id", PageController, :application_details
    post "/approve/application/:id", PageController, :approve_application
  end

  # Other scopes may use custom stacks.
  # scope "/api", TandemWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tandem, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TandemWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
