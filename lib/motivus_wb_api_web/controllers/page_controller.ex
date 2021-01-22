defmodule MotivusWbApiWeb.PageController do
  use MotivusWbApiWeb, :controller
  alias MotivusWbApi.Users

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
