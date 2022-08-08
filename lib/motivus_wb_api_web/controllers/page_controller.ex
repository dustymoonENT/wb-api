defmodule MotivusWbApiWeb.PageController do
  use MotivusWbApiWeb, :controller
  alias MotivusWbApi.TaskPool

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def tasks_queue_total(conn, _params) do
    public = length(TaskPool.list(:public_task_pool))
    private = length(TaskPool.list(:private_task_pool))
    json(conn, %{data: %{tasks_queue_total: %{public: public, private: private}}})
  end
end
