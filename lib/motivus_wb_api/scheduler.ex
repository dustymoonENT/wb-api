defmodule MotivusWbApi.Scheduler do
  alias Phoenix.PubSub

  def match() do
    case [
      MotivusWbApi.QueueNodes.pop(MotivusWbApi.QueueNodes),
      MotivusWbApi.QueueTasks.pop(MotivusWbApi.QueueTasks)
    ] do
      [:error, :error] ->
        nil

      [data_node, :error] ->
        MotivusWbApi.QueueNodes.push_top(MotivusWbApi.QueueNodes, data_node)

      [:error, data_task] ->
        MotivusWbApi.QueueTasks.push(MotivusWbApi.QueueTasks, data_task)

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
