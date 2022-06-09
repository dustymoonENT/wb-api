defmodule MotivusWbApiWeb.PageController do
  use MotivusWbApiWeb, :controller
  alias MotivusWbApi.TaskPool

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def tasks_queue_total(conn, _params) do
    total = length(TaskPool.list(TaskPool))
    json(conn, %{data: %{tasks_queue_total: total}})
  end
end
