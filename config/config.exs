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
  url: [host: System.get_env("HOST_NAME", "localhost")],
  secret_key_base: "Vsc6+GXozWi0VJnnqMVN/zuK+n2sc+be9Yzx1bHhHslg0LM8lODExpQTrfaQhtSS",
  render_errors: [view: MotivusWbApiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MotivusWbApi.PubSub,
  live_view: [signing_salt: "rYhQaecI"]

config :motivus_wb_api, MotivusWbApi.Users.Guardian,
  issuer: "motivus_wb_api",
  secret_key: "+3LwaCzii9+KPeqbfDIAPfPOlKZGUAwKeI9v8bGiL4VzC+99MaetabswT6HoBvi1"

config :motivus_wb_api,
  spa_origin: System.get_env("SPA_ORIGIN", "https://motivus.cl"),
  spa_alias_origin: System.get_env("SPA_ALIAS_ORIGIN", "https://www.motivus.cl"),
  external_user_provider_uri:
    System.get_env(
      "EXTERNAL_USER_PROVIDER_URI",
      "https://marketplace.api.motivus.cl/api/account/user"
    )

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]},
    facebook: {Ueberauth.Strategy.Facebook, [default_scope: "email,public_profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")

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
