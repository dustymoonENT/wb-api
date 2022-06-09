defmodule MotivusWbApi.Scheduler do
  alias Phoenix.PubSub

  def match() do
    case [
      MotivusWbApi.ThreadPool.pop(MotivusWbApi.ThreadPool),
      MotivusWbApi.TaskPool.pop(MotivusWbApi.TaskPool)
    ] do
      [:error, :error] ->
        nil

      [data_node, :error] ->
        MotivusWbApi.ThreadPool.push_top(MotivusWbApi.ThreadPool, data_node)

      [:error, data_task] ->
        MotivusWbApi.TaskPool.push(MotivusWbApi.TaskPool, data_task)

      [data_node, data_task] ->
        dispatch(data_node, data_task)
    end
  end

  def dispatch(data_node, data_task) do
    PubSub.broadcast(
      MotivusWbApi.PubSub,
      "dispatch",
      {"worker_task_match", :unused, %{data_node: data_node, data_task: data_task}}
    )
  end
end
