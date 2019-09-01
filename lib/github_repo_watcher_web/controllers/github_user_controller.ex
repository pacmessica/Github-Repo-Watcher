defmodule GithubRepoWatcherWeb.GithubUserController do
  use GithubRepoWatcherWeb, :controller
  @github_client Application.get_env(:github_repo_watcher, :github_client)

  def show(conn, params) do
    username = Map.get(params, "username")

    if username == nil do
      conn
      |> put_flash(:info, "username must be provided")
      |> redirect(to: "/")
    else
      {cursor, cursor_type} =
        if Map.has_key?(params, "beforeCursor") do
          {Map.get(params, "beforeCursor"), "before"}
        else
          {Map.get(params, "afterCursor", ""), "after"}
        end

      case @github_client.get_user(username, cursor, cursor_type) do
        {:ok, user} ->
          github_user = %{
            name: user.name,
            avatar_url: user.avatarUrl,
            username: username,
            location: user.location,
            repos: user.watching.nodes,
            pageInfo: user.watching.pageInfo
          }

          render(conn, "show.html", github_user: github_user)

        {:error, error} ->
          conn
          |> put_flash(:error, error)
          |> redirect(to: "/")
      end
    end
  end
end
