# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :github_repo_watcher, GithubRepoWatcherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0nAC3XhaTOEUfcc6iVgFd3m40fQBoLb6sdgpMKjON/3F5d0LSxA+ThSpKIHhfPOw",
  render_errors: [view: GithubRepoWatcherWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: GithubRepoWatcher.PubSub, adapter: Phoenix.PubSub.PG2]

config :github_repo_watcher,
  github_client: GithubRepoWatcher.GithubClient

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
