defmodule MotivusWbApi.Listeners.Match do
  use GenServer
  import MotivusWbApi.CommonActions

  def start_link(context) do
    GenServer.start_link(__MODULE__, context)
  end

  def init(context) do
    Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "matches:" <> context.scope)
    {:ok, context}
  end

  def handle_info({"POOL_UPDATED", _data}, context) do
    try_match(context.thread_pool, context.task_pool, context.scope)
    {:noreply, context}
  end
end
