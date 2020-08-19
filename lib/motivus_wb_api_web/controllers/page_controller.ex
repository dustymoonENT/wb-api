defmodule MotivusWbApiWeb.PageController do
  use MotivusWbApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
