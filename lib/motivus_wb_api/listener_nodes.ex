defmodule MotivusWbApi.ListenerNodes do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.ThreadPool.Thread

  import MotivusWbApi.CommonActions

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    PubSub.subscribe(MotivusWbApi.PubSub, "nodes")
    {:ok, opts}
  end

  def handle_info({"new_channel", _, %{channel_id: channel_id}}, context) do
    broadcast_user_stats(channel_id)

    {:noreply, context}
  end

  def handle_info({"new_thread", _name, %Thread{} = thread}, context) do
    register_thread(thread, context.thread_pool)
    maybe_match_task_to_thread()
    broadcast_user_stats(thread.channel_id)

    {:noreply, context}
  end

  def handle_info({"dead_channel", _name, %{channel_id: channel_id}}, context) do
    deregister_threads(channel_id, context.thread_pool)
    maybe_retry_dropped_tasks(channel_id, context.processing_registry)

    {:noreply, context}
  end
end
