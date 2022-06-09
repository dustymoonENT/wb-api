defmodule MotivusWbApi.ListenerTasks do
  use GenServer
  alias Phoenix.PubSub

  import MotivusWbApi.CommonActions

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    PubSub.subscribe(MotivusWbApi.PubSub, "tasks")
    {:ok, opts}
  end

  def handle_info({"new_task", _name, data}, %{queue_tasks: queue} = context) do
    prepare_task(data)
    |> enqueue_task(queue)

    maybe_match_task_to_node()

    {:noreply, context}
  end

  def handle_info({"retry_task", _name, data}, %{queue_tasks: queue} = context) do
    enqueue_task(data, queue)

    maybe_match_task_to_node()

    {:noreply, context}
  end

  def handle_info({"dead_client", _name, %{channel_id: channel_id}}, context) do
    # TODO update dequeued tasks with aborted_on
    dequeue_tasks(channel_id, context.queue_tasks)

    maybe_stop_tasks(channel_id, context.queue_processing)
    |> mark_aborted_tasks()

    {:noreply, context}
  end
end
