defmodule MotivusWbApi.Listeners.Dispatch do
  use GenServer
  alias Phoenix.PubSub
  import MotivusWbApi.CommonActions

  def start_link(context) do
    GenServer.start_link(__MODULE__, context)
  end

  def init(context) do
    PubSub.subscribe(MotivusWbApi.PubSub, "dispatch")
    {:ok, context}
  end

  def handle_info({"TASK_ASSIGNED", %{thread: thread, task: task}}, context) do
    update_task_worker(task, thread)
    deliver_task(task, thread)
    register_task_assignment(task, thread, context.processing_registry)

    broadcast_user_stats(thread.channel_id)
    {:noreply, context}
  end
end
