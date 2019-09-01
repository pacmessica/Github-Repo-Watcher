use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :github_repo_watcher, GithubRepoWatcherWeb.Endpoint,
  http: [port: 4002],
  server: false

config :github_repo_watcher,
  github_client: GithubRepoWatcher.GithubClientMock

# Print only warnings and errors during test
config :logger, level: :warn
