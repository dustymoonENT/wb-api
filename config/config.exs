# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :motivus_wb_api,
  ecto_repos: [MotivusWbApi.Repo]

# Configures the endpoint
config :motivus_wb_api, MotivusWbApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Vsc6+GXozWi0VJnnqMVN/zuK+n2sc+be9Yzx1bHhHslg0LM8lODExpQTrfaQhtSS",
  render_errors: [view: MotivusWbApiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MotivusWbApi.PubSub,
  live_view: [signing_salt: "rYhQaecI"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: &MotivusWbApiWeb.Endpoint.match_origin/1,
  max_age: 86400,
  methods: ["GET", "POST"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
