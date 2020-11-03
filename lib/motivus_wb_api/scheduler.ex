defmodule MotivusWbApi.Scheduler do

  def match() do
    case [MotivusWbApi.QueueNodes.pop(MotivusWbApi.QueueNodes), MotivusWbApi.QueueTasks.pop(MotivusWbApi.QueueTasks)] do
      [:error, :error] ->
        IO.inspect("Queues are empty")

      [data_node, :error] ->
        MotivusWbApi.QueueNodes.push_top(MotivusWbApi.QueueNodes, data_node)
        IO.inspect("Tasks queue is empty")

      [:error, data_task] ->
        MotivusWbApi.QueueTasks.push(MotivusWbApi.QueueTasks, data_task)
        IO.inspect("Nodes queue is empty")

      [data_node, data_task] ->
        IO.inspect(label: "Es un match")
        dispatch(data_node, data_task)
    end
  end

  def dispatch(data_node, data_task) do
    #id = data_task[:id] 
    #payload = get(http://ruta_a_api_de_negocio/tareas/<id>)
    MotivusWbApiWeb.Endpoint.broadcast!(
      "room:worker:" <> data_node[:id],
      "new_msg",
      data_task
    )
    #IO.inspect(label: "Scheduling task on a node")
    #IO.inspect(node: data_node)
    #IO.inspect(task: data_task)
  end
end
