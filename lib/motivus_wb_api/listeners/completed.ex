defmodule MotivusWbApi.Listeners.Completed do
  use GenServer
  alias MotivusWbApiWeb.Channels.Worker.Result
  alias MotivusWbApi.ThreadPool.Thread
  import MotivusWbApi.CommonActions

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    Phoenix.PubSub.subscribe(MotivusWbApi.PubSub, "completed")
    {:ok, opts}
  end

  def handle_info(
        {"TASK_COMPLETED", _, {%Thread{} = thread, %Result{} = result}},
        %{processing_registry: registry} = context
      ) do
    task = deregister_task_assignment(thread, registry)

    update_task_result(task, result)
    send_task_result(task, result)

    broadcast_user_stats(thread.channel_id)

    {:noreply, context}
  end
end
