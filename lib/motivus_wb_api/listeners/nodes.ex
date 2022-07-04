defmodule MotivusWbApi.Listeners.Node do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.ThreadPool.Thread

  import MotivusWbApi.CommonActions

  def start_link(context) do
    GenServer.start_link(__MODULE__, context)
  end

  def init(context) do
    PubSub.subscribe(MotivusWbApi.PubSub, "nodes:" <> context.scope)
    {:ok, context}
  end

  def handle_info({"WORKER_CHANNEL_OPENED", %{channel_id: channel_id}}, context) do
    broadcast_user_stats(channel_id)

    {:noreply, context}
  end

  def handle_info({"THREAD_AVAILABLE", %Thread{} = thread}, context) do
    register_thread(thread, context.thread_pool)
    maybe_match_task_to_thread(context.scope)
    broadcast_user_stats(thread.channel_id)

    {:noreply, context}
  end

  def handle_info({"WORKER_CHANNEL_CLOSED", %{channel_id: channel_id}}, context) do
    deregister_threads(channel_id, context.thread_pool)
    drop_running_tasks(channel_id, context.processing_registry)

    {:noreply, context}
  end
end
