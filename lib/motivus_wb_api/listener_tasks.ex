defmodule MotivusWbApi.ListenerTasks do
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.TaskPool.TaskDefinition
  alias MotivusWbApi.TaskPool.Task

  import MotivusWbApi.CommonActions

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(opts) do
    PubSub.subscribe(MotivusWbApi.PubSub, "tasks")
    {:ok, opts}
  end

  def handle_info({"new_task", _name, %TaskDefinition{} = task_def}, %{task_pool: pool} = context) do
    prepare_task(task_def)
    |> add_task(pool)

    maybe_match_task_to_thread()

    {:noreply, context}
  end

  def handle_info({"retry_task", _name, %Task{} = task}, %{task_pool: pool} = context) do
    add_task(task, pool)
    maybe_match_task_to_thread()

    {:noreply, context}
  end

  def handle_info({"dead_client", _name, %{channel_id: channel_id}}, context) do
    # TODO update depoold tasks with aborted_on
    remove_tasks(channel_id, context.task_pool)

    maybe_stop_tasks(channel_id, context.processing_registry)
    |> mark_aborted_tasks()

    {:noreply, context}
  end
end
