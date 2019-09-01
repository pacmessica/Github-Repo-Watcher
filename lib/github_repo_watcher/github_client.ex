defmodule GithubRepoWatcher.GithubClient do
  @behaviour GithubRepoWatcher.GithubClientBehaviour

  require Logger

  @impl GithubRepoWatcher.GithubClientBehaviour
  def get_user(username, cursor, cursor_type) do
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
