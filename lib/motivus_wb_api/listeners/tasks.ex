defmodule MotivusWbApi.Listeners.Task do
  @moduledoc """
  Listens for task events.

  The listener is responsible for keeping track of the tasks and react when a task is queued for completion, unable to finish and cancelled by the client.
  """
  use GenServer
  alias Phoenix.PubSub
  alias MotivusWbApi.TaskPool.TaskDefinition
  alias MotivusWbApi.TaskPool.Task

  import MotivusWbApi.Processing.Actions

  def start_link(context) do
    GenServer.start_link(__MODULE__, context)
  end

  def init(context) do
    PubSub.subscribe(MotivusWbApi.PubSub, "tasks:" <> context.scope)
    {:ok, context}
  end

  def handle_info({"NEW_TASK_DEFINITION", %TaskDefinition{} = task_def}, context) do
    prepare_task(task_def)
    |> add_task(context.task_pool)

    maybe_match_task_to_thread(context.scope)

    {:noreply, context}
  end

  def handle_info({"UNFINISHED_TASK", %Task{} = task}, context) do
    add_task(task, context.task_pool)
    maybe_match_task_to_thread(context.scope)

    {:noreply, context}
  end

  def handle_info({"CLIENT_CHANNEL_CLOSED", %{channel_id: channel_id}}, context) do
    # TODO update depoold tasks with aborted_on
    remove_tasks(channel_id, context.task_pool)

    maybe_stop_tasks(channel_id, context.processing_registry)
    |> mark_aborted_tasks()

    {:noreply, context}
  end
end
