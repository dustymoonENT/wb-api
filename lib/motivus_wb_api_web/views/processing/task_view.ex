defmodule MotivusWbApiWeb.Processing.TaskView do
  use MotivusWbApiWeb, :view
  alias MotivusWbApiWeb.Processing.TaskView

  def render("index.json", %{tasks: tasks}) do
    %{data: render_many(tasks, TaskView, "task.json")}
  end

  def render("show.json", %{task: task}) do
    %{data: render_one(task, TaskView, "task.json")}
  end

  def render("task.json", %{task: task}) do
    %{id: task.id,
      type: task.type,
      params: task.params,
      date_in: task.date_in,
      date_last_dispatch: task.date_last_dispatch,
      date_out: task.date_out,
      attempts: task.attempts,
      flops: task.flops,
      processing_base_time: task.processing_base_time}
  end
end
