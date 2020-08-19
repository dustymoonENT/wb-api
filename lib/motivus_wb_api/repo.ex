defmodule MotivusWbApi.Repo do
  use Ecto.Repo,
    otp_app: :motivus_wb_api,
    adapter: Ecto.Adapters.Postgres
end
