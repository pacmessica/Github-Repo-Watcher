defmodule GithubRepoWatcherWeb.GithubUserController do
  use GithubRepoWatcherWeb, :controller
  require Logger

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

      case get_github_user(username, cursor, cursor_type) do
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

  defp get_github_user(username, cursor, cursor_type) do
    token = System.get_env("GITHUB_TOKEN")

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.post(
        "https://api.github.com/graphql",
        build_user_query(username, cursor, cursor_type),
        [{"Authorization", "bearer #{token}"}, {"Content-Type", "application/json"}]
      )

    result = Poison.decode!(body, keys: :atoms)

    if Map.has_key?(result, :errors) do
      err = hd(result.errors)

      case Map.get(err, "type") do
        "NOT_FOUND" ->
          {:error, "Github user '#{username}' not found"}

        _ ->
          Logger.error("Error when calling github api: #{err.message}")
          {:error, "Internal Error"}
      end
    else
      {:ok, result.data.user}
    end
  end

  defp build_user_query(username, cursor, input_cursor_type) do
    {limit_type, cursor_type} =
      if input_cursor_type == "before" do
        {"last", "before"}
      else
        {"first", "after"}
      end

    {:ok, graphql} =
      Poison.encode(%{
        query: """
        query($username:String!, $cursor:String!) {
          user(login: $username) {
            avatarUrl
            location
            name
            watching(#{limit_type}:15 #{cursor_type}: $cursor) {
              pageInfo {
                startCursor
                endCursor
                hasNextPage
                hasPreviousPage
              }
              nodes {
                name
                description
                url
              }
            }
          }
        }
        """,
        variables: %{username: username, cursor: cursor}
      })

    graphql
  end
end
