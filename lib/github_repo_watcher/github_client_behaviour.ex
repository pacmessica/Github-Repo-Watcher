defmodule GithubRepoWatcher.GithubClientBehaviour do
  @type user :: map

  @callback get_user(String.t(), String.t(), String.t()) ::
              {:ok, user} | {:error, String.t()}
end
