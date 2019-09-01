defmodule GithubRepoWatcherWeb.GithubUserControllerTest do
  use GithubRepoWatcherWeb.ConnCase
  import Mox
  setup :verify_on_exit!

  def test_user(username) do
    %{
      name: "Test User",
      avatarUrl: "",
      username: username,
      location: "Kalamazoo",
      watching: %{
        nodes: [
          %{
            name: "test repo",
            description: "",
            url: "https://github.com/test"
          }
        ],
        pageInfo: %{
          startCursor: "",
          endCursor: "",
          hasNextPage: true,
          hasPreviousPage: false
        }
      }
    }
  end

  describe "show" do
    test "redirects when github user is missing in params", %{conn: conn} do
      conn = get(conn, Routes.github_user_path(conn, :show))

      assert html_response(conn, 302) =~
               "<html><body>You are being <a href=\"/\">redirected</a>.</body></html>"
    end

    test "shows github user", %{conn: conn} do
      username = "testuser123"

      expect(GithubRepoWatcher.GithubClientMock, :get_user, fn _, _, _ ->
        {:ok, test_user(username)}
      end)

      conn = get(conn, Routes.github_user_path(conn, :show, %{username: username}))

      assert html_response(conn, 200) =~ username
    end
  end
end
