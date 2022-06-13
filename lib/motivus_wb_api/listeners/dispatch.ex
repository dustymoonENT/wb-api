defmodule MotivusWbApi.Listeners.Dispatch do
  use GenServer
  alias Phoenix.PubSub
  import MotivusWbApi.CommonActions

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    PubSub.subscribe(MotivusWbApi.PubSub, "dispatch")
    {:ok, opts}
  end

  def handle_info({"TASK_ASSIGNED", _name, %{thread: thread, task: task}}, context) do
    update_task_worker(task, thread)
    deliver_task(task, thread)
    register_task_assignment(task, thread, context.processing_registry)

    broadcast_user_stats(thread.channel_id)
    {:noreply, context}
  end
end
