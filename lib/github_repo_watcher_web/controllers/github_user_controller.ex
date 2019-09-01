defmodule GithubRepoWatcherWeb.GithubUserController do
  use GithubRepoWatcherWeb, :controller

	def show(conn, _params) do
		render(conn, "show.html")
	end
end
