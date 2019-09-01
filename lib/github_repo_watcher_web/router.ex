defmodule GithubRepoWatcherWeb.Router do
  use GithubRepoWatcherWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GithubRepoWatcherWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/github_users", GithubUserController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", GithubRepoWatcherWeb do
  #   pipe_through :api
  # end
end
