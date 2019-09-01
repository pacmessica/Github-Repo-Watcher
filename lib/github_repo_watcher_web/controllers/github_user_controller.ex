defmodule GithubRepoWatcherWeb.GithubUserController do
  use GithubRepoWatcherWeb, :controller
  require Logger

  def show(conn, %{"username" => username}) do
    case get_github_user(username) do
      {:ok, user} ->
        github_user = %{
          name: user.name,
          avatar_url: user.avatarUrl,
          location: user.location
        }

        render(conn, "show.html", github_user: github_user)

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: "/")
    end
  end

  defp get_github_user(username) do
    token = System.get_env("GITHUB_TOKEN")

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.post(
        "https://api.github.com/graphql",
        buildUserQuery(username),
        [{"Authorization", "bearer #{token}"}, {"Content-Type", "application/json"}]
      )

    result = Poison.decode!(body, keys: :atoms)

    if Map.has_key?(result, :errors) do
      err = hd(result.errors)

      case err.type do
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

  defp buildUserQuery(username) do
    {:ok, graphql} =
      Poison.encode(%{
        query: """
        query($username:String!) {
          user(login: $username) {
            avatarUrl
            location
            name
            watching(first:4) {
              pageInfo {
                endCursor
                hasNextPage
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
        variables: %{username: username}
      })

    graphql
  end
end
