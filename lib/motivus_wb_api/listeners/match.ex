defmodule MotivusWbApi.Listeners.Match do
  use GenServer
  import MotivusWbApi.CommonActions

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "matches")
    {:ok, opts}
  end

  def handle_info({"POOL_UPDATED", _, _data}, context) do
    try_match(context.thread_pool, context.task_pool)
    {:noreply, context}
  end
end
