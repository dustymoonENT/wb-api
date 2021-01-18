defmodule MotivusWbApiWeb.Processing.TaskController do
  use MotivusWbApiWeb, :controller

  alias MotivusWbApi.Processing
  alias MotivusWbApi.Processing.Task

  action_fallback MotivusWbApiWeb.FallbackController

  def index(conn, _params) do
    tasks = Processing.list_tasks()
    render(conn, "index.json", tasks: tasks)
  end

  def create(conn, %{"task" => task_params}) do
    with {:ok, %Task{} = task} <- Processing.create_task(task_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.processing_task_path(conn, :show, task))
      |> render("show.json", task: task)
    end
  end

  def show(conn, %{"id" => id}) do
    task = Processing.get_task!(id)
    render(conn, "show.json", task: task)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Processing.get_task!(id)

    with {:ok, %Task{} = task} <- Processing.update_task(task, task_params) do
      render(conn, "show.json", task: task)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Processing.get_task!(id)

    with {:ok, %Task{}} <- Processing.delete_task(task) do
      send_resp(conn, :no_content, "")
    end
  end
end
