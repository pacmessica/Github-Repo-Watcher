# GithubRepoWatcher

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Set up github token

In the root of our app, create a `.env` file. Save your github token to your .env file under the key `GITHUB_TOKEN`.


    export GITHUB_TOKEN=your_github_token


Type `source .env` for each terminal you are using (Note: you may need to restart the server).

To get a github token, follow the instructions [here](https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line).