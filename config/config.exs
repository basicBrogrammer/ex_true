# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ex_true,
  ecto_repos: [ExTrue.Repo]

# Configures the endpoint
config :ex_true, ExTrueWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "6qrv+Xq3EZPQo5siSNJXriF8pFyDhEMqML60A2cujmiGr6sn48S+g6FyA1ieAxMl",
  render_errors: [view: ExTrueWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExTrue.PubSub,
  live_view: [signing_salt: "qyqd27uK"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
