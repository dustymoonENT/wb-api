defmodule MotivusWbApiWeb.PageController do
  use MotivusWbApiWeb, :controller
  alias MotivusWbApi.Users

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def processing_preferences(conn, _params) do
    conn
    # |> put_resp_cookie("wb_pp", "random",
    #   domain: "api.motivus.afinitat.ml",
    #   same_site: "None",
    #   secure: true,
    #   max_age: 31_557_600
    # )
    |> json(%{"processing_allowed" => true})
  end

  def get_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    json(conn, %{"user" => user})
  end

  def create_guest(conn, _params) do
    {:ok, user} =
      Users.create_user(%{uuid: Ecto.UUID.bingenerate(), is_guest: true, name: "guest"})

    json(conn, %{"user" => user})
  end
end
