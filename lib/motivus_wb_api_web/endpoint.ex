defmodule MotivusWbApiWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :motivus_wb_api

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_motivus_wb_api_key",
    signing_salt: "xNwGcGxg"
  ]

  socket "/client_socket", MotivusWbApiWeb.ClientSocket,
    websocket: [timeout: 30_000, check_origin: false],
    longpoll: false

  socket "/socket", MotivusWbApiWeb.UserSocket,
    websocket: [timeout: 30_000, check_origin: false],
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :motivus_wb_api,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :motivus_wb_api
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  def match_origin(conn) do
    conn.req_headers
    |> Enum.filter(&match?({"origin", _}, &1))
    |> Enum.map(fn {_, origin} -> origin end)
  end

  plug CORSPlug
  plug MotivusWbApiWeb.Router
end
