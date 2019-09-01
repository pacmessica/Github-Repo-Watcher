defmodule GithubRepoWatcherWeb.GithubUserController do
  use GithubRepoWatcherWeb, :controller

  def show(conn, %{"username" => username}) do
    data = get_github_user(username)

    github_user = %{
      name: data.name,
      avatar_url: data.avatarUrl,
      location: data.location
    }

    render(conn, "show.html", github_user: github_user)
  end

  defp get_github_user(username) do
    token = System.get_env("GITHUB_TOKEN")

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.post(
        "https://api.github.com/graphql",
        Poison.encode!(%{"query" => query(username)}),
        [{"Authorization", "bearer #{token}"}, {"Content-Type", "application/json"}]
      )

    decode_json(body)
  end

  defp decode_json(body) do
    %{data: data} = Poison.decode!(body, keys: :atoms)
    data.user
  end

  defp query(username) do
    "query {
      user(login: \"#{username}\") {
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
    }"
  end
end
