defmodule MotivusWbApi.Listeners.Dispatch do
  @moduledoc """
  Listens for dispatch events.

  This module is responsible for delivering tasks to workers and keep track of the assignment.
  """
  use GenServer
  alias Phoenix.PubSub
  import MotivusWbApi.Processing.Actions

  def start_link(context) do
    GenServer.start_link(__MODULE__, context)
  end

  def init(context) do
    PubSub.subscribe(MotivusWbApi.PubSub, "dispatch:" <> context.scope)
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
